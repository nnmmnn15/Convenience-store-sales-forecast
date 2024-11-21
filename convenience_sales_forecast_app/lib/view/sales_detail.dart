import 'package:convenience_sales_forecast_app/vm/map_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesDetail extends StatelessWidget {
  SalesDetail({super.key});

  // final mapHandler = Get.put(MapHandler());
  final MapHandler mapHandler = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => mapHandler.detailStateSwitch(),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Text(
                      '이전 분기 나이대별 유동인구',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Text('${(index + 1) * 10}대 유동인구 수'),
                                Text('100% = ${mapHandler.peoplesList[index]}'),
                              ],
                            ),
                          ],
                        ),
                        Slider(
                          activeColor: Colors.blue,
                          thumbColor: Colors.red,
                          value: mapHandler.feature1[index],
                          min: 90,
                          max: 110,
                          divisions: 20,
                          onChanged: (value) {
                            mapHandler.feature1[index] = value;
                            // setState(() {
                            //   mapHandler.feature1[index] = value;
                            // });
                          },
                        ),
                        Text('${mapHandler.feature1[index].toInt()}%'),
                        // SizedBox(height: 20), // 각 슬라이더 사이의 간격
                      ],
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // 전송 함수
                    mapHandler.forecast();
                  },
                  child: const Text('적용'),
                ),
              ),
              // !!매출
              Obx(
                () => Text(
                  '해당 지역 편의점 개점시 예상 매출은 \n ${mapHandler.wirteSale(mapHandler.salesForecast)}원',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    color: Colors.blue,
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: const Text('차트1'),
                  ),
                  Container(
                    color: Colors.blue,
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: const Text('차트2'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      inputAlert();
                    },
                    child: const Text('저장'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- Functions ---
  // 적용 완료 알람창
  buttonDialog() {
    Get.defaultDialog(
      title: "결과",
      middleText: '저장이 완료되었습니다!',
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            mapHandler.isDetail.value = false;
            mapHandler.isPicked.value = false;
          },
          child: const Text('확인'),
        )
      ],
    );
  }

  // 별칭 입력창
  inputAlert() {
    Get.dialog(
      AlertDialog(
        title: const Text('이름 입력'),
        content: TextField(
          controller: mapHandler.textEditingController,
          decoration: const InputDecoration(hintText: "선택한 지점의 이름을 설정해주세요"),
        ),
        actions: [
          TextButton(
            child: const Text('확인'),
            onPressed: () {
              Get.back(); // 다이얼로그 닫기
              // 저장 알람
              mapHandler.saveStoreInf();
              buttonDialog();
              mapHandler.textEditingController.text = '';
            },
          ),
          TextButton(
            child: const Text('취소'),
            onPressed: () {
              mapHandler.textEditingController.text = '';
              Get.back(); // 다이얼로그 닫기
            },
          ),
        ],
      ),
    );
  }
}
