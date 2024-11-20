import 'package:convenience_sales_forecast_app/vm/map_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesDetail extends StatelessWidget {
  SalesDetail({super.key});

  final mapHandler = Get.put(MapHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 함수화 가능
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('특성 1'),
                            Text('범위'),
                          ],
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
                        Text(mapHandler.feature1.value.toInt().toString()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '해당 지역 편의점 개점시 예상 매출은 \n 1,475,438,000₩ ~ 1,682,438,000₩  입니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  color: Colors.blue,
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: const Text('차트1'),
                ),
                Container(
                  color: Colors.blue,
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: const Text('차트2'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    //
                    inputAlert();
                    //
                  },
                  child: const Text('저장'),
                ),
              ],
            )
          ],
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
