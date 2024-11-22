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
    // mapHandler.isDetail.value = false;

    mapHandler.isPicked.value = false;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Center(
        child: Stack(
          children: [
            // 지도
            flutterMap(),
            // 행정동 버튼, 영역 선택
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    // alignment: Alignment.topRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            '행정동  ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        DropdownButton(
                          dropdownColor: Colors.black,
                          iconEnabledColor: Colors.white,
                          value: mapHandler.dropdownValue.value, // 현재 값
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: mapHandler.dongNames.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(
                                items,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            mapHandler.changeLocate(value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 예상 매출 금액 팝업
            Obx(
              () => mapHandler.isPicked.value
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.6,
                              height: MediaQuery.sizeOf(context).height * 0.23,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25)),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start, // Row 내부 정렬
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Row의 가로 정렬
                                      children: [
                                        // 예상 매출 금액
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start, // Column 내부 정렬
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '예상 매출 금액',
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${mapHandler.wirteSale(mapHandler.salesForecast)}원',
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // 선택한 지역
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start, // Column 내부 정렬
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              '선택한 지역 :\t\t${mapHandler.selectDongName}',
                                              style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${mapHandler.selectDongName} 편의점 수 : \t${mapHandler.storeCount.value}',
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: double.infinity, // 가로를 화면 전체로 확장
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16), // 버튼 높이 조정 (선택 사항)
                                        ),
                                        onPressed: () async{
                                          await mapHandler.detailStateSwitch();
                                          mapHandler.feature1.value = [100, 100, 100, 100, 100];
                                          await mapHandler.otherForecast();
                                        },
                                        child: const Text('시뮬레이션'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
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
    mapHandler.isRun.value = true;
    return FlutterMap(
      mapController: mapHandler.mapController,
      options: MapOptions(
        initialCenter: mapHandler.startPoint,

        // 화면 배율 초기값
        initialZoom: 16.0,
        // 최소값
        minZoom: 14.0,
        // 최댓값
        maxZoom: 19.0,

        // 회전 잠금
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        // 화면 터치시 동작
        onTap: (tapPosition, point) async {
          // print("${point.latitude}, ${point.longitude}");
          await mapHandler.selectPoint(point.latitude, point.longitude);
          if (!mapHandler.dongNames.contains(mapHandler.selectDongName.value)) {
            errorAlert();
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),

        // 선택 상태 일 경우 마커 표시
        // 마커
        Obx(
          () => PolygonLayer(
            polygons: [
              Polygon(
                points: mapHandler.dongPolygon,
                color: Colors.blue.withOpacity(0.3), // 폴리곤 내부 색상
                borderStrokeWidth: 3.0,
                borderColor: Colors.blue, // 폴리곤 경계 색상
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Functions ---
  errorAlert() {
    Get.defaultDialog(
      title: "정보",
      middleText: '지원하지 않는 행정동 입니다.',
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            mapHandler.isPicked.value = false;
            mapHandler.resetPolygon();
          },
          child: const Text('확인'),
        )
      ],
    );
  }
}
