import 'package:convenience_sales_forecast_app/model/store_history.dart';
import 'package:convenience_sales_forecast_app/vm/map_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;

class SalesHistory extends StatelessWidget {
  SalesHistory({super.key});

  final mapHandler = Get.put(MapHandler());

  @override
  Widget build(BuildContext context) {
    // 초기값 설정
    mapHandler.selectedStore.value = false;
    mapHandler.selectedIndex.value = -1;
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Obx(
                  () => ListView.builder(
                    itemCount: mapHandler.histList.length,
                    itemBuilder: (context, index) {
                      StoreHistory storeInfo = mapHandler.histList[index];
                      return GestureDetector(
                          onTap: () {
                            if (mapHandler.isRun.value) {
                              mapHandler.mapController.move(
                                latlng.LatLng(storeInfo.lat, storeInfo.lng),
                                16,
                              );
                            }
                            mapHandler.selectedIndex.value = index;
                            mapHandler.selectedStore.value = true;
                            mapHandler.feature1.value =
                                storeInfo.features.toDouble();
                          },
                          child: Obx(
                            () => Card(
                              color: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                  color: mapHandler.selectedIndex.value == index
                                      ? Colors.blue // 선택된 항목의 테두리 색상 변경
                                      : Colors.transparent,
                                  width: 2.0,
                                ),
                              ),
                              elevation: 3,
                              child: ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      storeInfo.alias,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '예상 매출 : ${storeInfo.salesResult}원',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ));
                    },
                  ),
                ),
              ),
            ),
            Obx(
              () => Flexible(
                flex: 5,
                child: mapHandler.selectedStore.value
                    ? storeDetail(context,
                        mapHandler.histList[mapHandler.selectedIndex.value])
                    : const Center(
                        child: Text(
                        '저장한 매장위치를 선택하세요',
                        style: TextStyle(fontSize: 24),
                      )),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- Widget ---
  Widget storeDetail(BuildContext context, StoreHistory storeInfo) {
    return Center(
      child: Stack(
        children: [
          flutterMap(storeInfo),
          // 하단 팝업
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () => mapHandler.updateHistory(storeInfo),
                        child: const Text('변경하기')),
                  ],
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * 0.25,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // 함수화 가능
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('특성 1'),
                                    Text('범위'),
                                  ],
                                ),
                              ),
                              Slider(
                                activeColor: Colors.blue, // 선택 영역 색
                                // inactiveColor: Colors.green, // 빈 영역 색
                                thumbColor: Colors.red, // 동그라미 색
                                value: mapHandler.feature1.value,
                                // !!최대 최소 변경
                                min: 0,
                                max: 100,
                                divisions: 100,
                                onChanged: (value) {
                                  mapHandler.feature1.value = value;
                                },
                              ),
                              Text(
                                  mapHandler.feature1.value.toInt().toString()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 지도
  Widget flutterMap(StoreHistory storeInfo) {
    mapHandler.isRun.value = true;
    return FlutterMap(
      mapController: mapHandler.mapController,
      options: MapOptions(
        initialCenter: latlng.LatLng(storeInfo.lat, storeInfo.lng),

        // 화면 배율 초기값
        initialZoom: 16.0,
        // 최소값
        minZoom: 16.0,
        // 최댓값
        maxZoom: 19.0,

        // 회전 잠금
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),

        // 마커
        MarkerLayer(
          markers: [
            Marker(
              width: 80,
              height: 80,
              point: latlng.LatLng(storeInfo.lat, storeInfo.lng),
              child: Column(
                children: [
                  SizedBox(
                    child: Text(
                      storeInfo.alias,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.location_on,
                    size: 50,
                    color: Colors.red,
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
