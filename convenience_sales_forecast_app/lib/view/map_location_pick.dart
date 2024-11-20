import 'package:convenience_sales_forecast_app/view/sales_detail.dart';
import 'package:convenience_sales_forecast_app/vm/map_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

class MapLocationPick extends StatelessWidget {
  MapLocationPick({super.key});

  final mapHandler = Get.put(MapHandler());

  @override
  Widget build(BuildContext context) {
    mapHandler.isDetail.value = false;
    mapHandler.isPicked.value = false;
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            // 지도
            flutterMap(),

            // 행정동 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => mapHandler.changeLocate(0),
                  child: const Text('신촌동'),
                ),
                ElevatedButton(
                  onPressed: () => mapHandler.changeLocate(1),
                  child: const Text('안암동'),
                ),
              ],
            ),

            // 예상 매출 금액 팝업
            Obx(
              () => mapHandler.isPicked.value
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.6,
                              height: MediaQuery.sizeOf(context).height * 0.15,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '예상 매출 금액',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // !!매장수 변수로 변경
                                        Text(
                                          '근처 매장수 : 4',
                                          style: TextStyle(
                                            fontSize: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '100,000,000 ~ 120,000,000',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ElevatedButton(
                                            onPressed: () =>
                                                mapHandler.detailStateSwitch(),
                                            child: const Text('환경 변경하기'))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton(
                    dropdownColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    iconEnabledColor: Theme.of(context).colorScheme.secondary,
                    value: mapHandler.dropdownValue.value, // 현재 값
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: mapHandler.rangeList.map((int items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(
                          items.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      mapHandler.setRange(value!);
                    },
                  ),
                ],
              ),
            ),
            Obx(
              () => SlideTransition(
                position: mapHandler.offsetAnimation,
                child: mapHandler.isDetail.value
                    ? SalesDetail()
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Widgets --
  Widget flutterMap() {
    return FlutterMap(
      mapController: mapHandler.mapController,
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: mapHandler.bound,
        ),

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
        // 화면 터치시 동작
        onTap: (tapPosition, point) {
          mapHandler.selectPoint(point.latitude, point.longitude);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),

        // 선택 상태 일 경우 마커 표시
        // 영역
        Obx(
          () => mapHandler.isPicked.value
              ? CircleLayer(
                  circles: [
                    CircleMarker(
                      point: mapHandler.selectLatLng.value,
                      radius: mapHandler.dropdownValue.value
                          .toDouble(), // 반경 (미터 단위)
                      useRadiusInMeter: true,
                      color: Colors.blue.withOpacity(0.3), // 원 내부 색상
                      borderColor: Colors.blue, // 원 테두리 색상
                      borderStrokeWidth: 2, // 테두리 두께
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        // 마커
        Obx(
          () => mapHandler.isPicked.value
              ? MarkerLayer(
                  markers: [
                    Marker(
                      width: 80,
                      height: 80,
                      point: mapHandler.selectLatLng.value,
                      child: const Column(
                        children: [
                          SizedBox(
                            child: Text(
                              '위치',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.location_on,
                            size: 50,
                            color: Colors.red,
                          )
                        ],
                      ),
                    )
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
