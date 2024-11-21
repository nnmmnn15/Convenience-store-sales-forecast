import 'package:convenience_sales_forecast_app/vm/map_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
               Padding(
                padding: const EdgeInsets.fromLTRB(0,5,0,10),
                child: Row(
                  children: [
                    Card(
                      color: Colors.brown[100],
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), 
                      ),
                      child: const Padding( 
                        padding:EdgeInsets.fromLTRB(12,4,12,4),
                        child: Text(
                          '이전 분기 나이대별 유동인구',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Stack(
                  children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blueGrey[100],
                    ),
                    height: MediaQuery.of(context).size.height/6,
                    width: MediaQuery.of(context).size.width/1.05,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height/14,
                    width: MediaQuery.of(context).size.width/1.05,
                    color: Colors.blueGrey[200],
                  ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(5, (index) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding:const EdgeInsets.fromLTRB(12,2,12,0),
                                      child: Text(
                                        '${(index + 1) * 10}대 유동인구 수', 
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      
                                      child: Text('100% = ${mapHandler.peoplesList[index]}')
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Slider(
                              activeColor: Colors.blue[400],
                              thumbColor: Colors.red[300],
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

                  ]
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () {
                    // 전송 함수
                    mapHandler.forecast();
                    mapHandler.otherForecast();
                  },
                  child: const Text('변화된 매출 에측하기'),
                ),
              ),
              // !!매출
              Obx(
                () => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black)
                    ),
                    child: Text(
                      '해당 지역 편의점 개점시 예상 매출은 ${mapHandler.wirteSale(mapHandler.salesForecast)}원(₩) 입니다.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Container(
                  //   color: Colors.blue,
                  //   width: MediaQuery.of(context).size.width * 0.35,
                  //   height: MediaQuery.of(context).size.height * 0.3,
                  //   child: const Text('차트1'),
                  // ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Obx(
                      () => SfCartesianChart(
                        primaryXAxis: const CategoryAxis(),
                        primaryYAxis: const NumericAxis(),
                        series: [
                          ColumnSeries<dynamic, String>(
                            dataSource: mapHandler.otherPlaceSales.value,
                            xValueMapper: (dynamic region, _) => region.name,
                            yValueMapper: (dynamic region, _) => region.value,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
                          )
                        ],
                        title: const ChartTitle(text: '지역별 데이터'),
                        // legend: const Legend(isVisible: true),
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                    ),
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
