import 'package:convenience_sales_forecast_app/model/store_history.dart';
import 'package:convenience_sales_forecast_app/vm/map_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;

class SalesHistory extends StatelessWidget {
  SalesHistory({super.key});

  final mapHandler = Get.put(MapHandler());
  // final MapHandler mapHandler = Get.find();

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
                                14,
                              );
                              mapHandler.selectLatLng.value =
                                  latlng.LatLng(storeInfo.lat, storeInfo.lng);
                              mapHandler.getPolygon();
                            }
                            mapHandler.selectedIndex.value = index;
                            mapHandler.selectedStore.value = true;
                            mapHandler.feature1.value = storeInfo.features
                                .cast<num>()
                                .map((e) => e.toDouble())
                                .toList();
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(3, (index) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Text('${(index + 1) * 10}대 유동인구 수'),
                                          Text('100% = !!인구수'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Slider(
                                    activeColor: Colors.blue,
                                    thumbColor: Colors.red,
                                    value: mapHandler.feature1[index],
                                    min: 70,
                                    max: 150,
                                    divisions: 80,
                                    onChanged: (value) {
                                      mapHandler.feature1[index] = value;
                                    },
                                  ),
                                  Text(
                                      '${mapHandler.feature1[index].toInt()}%'),
                                  // SizedBox(height: 20), // 각 슬라이더 사이의 간격
                                ],
                              );
                            }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(2, (index) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Text('${(index + 4) * 10}대 유동인구 수'),
                                          Text('100% = !!인구수'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Slider(
                                    activeColor: Colors.blue,
                                    thumbColor: Colors.red,
                                    value: mapHandler.feature1[index + 3],
                                    min: 70,
                                    max: 150,
                                    divisions: 80,
                                    onChanged: (value) {
                                      mapHandler.feature1[index + 3] = value;
                                    },
                                  ),
                                  Text(
                                      '${mapHandler.feature1[index + 3].toInt()}%'),
                                  // SizedBox(height: 20), // 각 슬라이더 사이의 간격
                                ],
                              );
                            }),
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
        minZoom: 13.5,
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

        // polygon
        PolygonLayer(
          polygons: [
            Polygon(
              points: mapHandler.dongPolygon,
              color: Colors.blue.withOpacity(0.3), // 폴리곤 내부 색상
              borderStrokeWidth: 3.0,
              borderColor: Colors.blue, // 폴리곤 경계 색상
            ),
          ],
        ),
      ],
    );
  }
}
