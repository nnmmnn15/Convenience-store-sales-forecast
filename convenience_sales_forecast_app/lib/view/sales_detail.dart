import 'package:convenience_sales_forecast_app/model/chart_model.dart';
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
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                child: Row(
                  children: [
                    Card(
                      color: Colors.indigo[100],
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
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
                () => Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blueGrey[100],
                    ),
                    height: MediaQuery.of(context).size.height / 6,
                    width: MediaQuery.of(context).size.width / 1.05,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 14,
                    width: MediaQuery.of(context).size.width / 1.05,
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
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 2, 12, 0),
                                    child: Text(
                                      '${(index + 1) * 10}대 유동인구 수',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                      child: Text(
                                          '100% = ${mapHandler.peoplesList[index]} 명')),
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
                            },
                          ),
                          Text('${mapHandler.feature1[index].toInt()}%'),
                        ],
                      );
                    }),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                  ),
                  onPressed: () {
                    // 전송 함수
                    mapHandler.forecast();
                    mapHandler.otherForecast();
                  },
                  child: const Text(
                    '변화된 매출 에측하기',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              // !!매출
              Obx(
                () => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Image.network(
                      'http://127.0.0.1:8000/view/${mapHandler.selectDongName.value}.png',
                      // width: ,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Obx(
                      () => SfCartesianChart(
                        primaryXAxis: const CategoryAxis(),
                        primaryYAxis: NumericAxis(
                          minimum: mapHandler.otherPlaceSales.isNotEmpty
                              ? mapHandler.otherPlaceSales
                                      .map((e) => e.value)
                                      .reduce((a, b) => a < b ? a : b) *
                                  0.8
                              : 0, // 최소값의 80%
                          maximum: mapHandler.otherPlaceSales.isNotEmpty
                              ? mapHandler.otherPlaceSales
                                      .map((e) => e.value)
                                      .reduce((a, b) => a > b ? a : b) *
                                  1.2
                              : 100, // 최대값의 120%
                          interval: 5000, // 눈금 간격
                        ),
                        series: [
                          ColumnSeries<ChartModel, String>(
                            dataSource: mapHandler.otherPlaceSales
                                .value, // 타입이 보장된 RxList<ChartModel>
                            xValueMapper: (ChartModel region, _) => region.name,
                            yValueMapper: (ChartModel region, _) =>
                                region.value,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
                            enableTooltip: true,
                          )
                        ],
                        title: const ChartTitle(text: '지역별 데이터'),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        inputAlert();
                      },
                      child: const Text('저장'),
                    ),
                  ],
                ),
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
        content: SizedBox(
          height: Get.size.height * 0.13,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  '저장 전에 예측버튼을 먼저 눌러주세요',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
              TextField(
                controller: mapHandler.textEditingController,
                decoration: const InputDecoration(hintText: "예측상황의 이름을 설정해주세요"),
              ),
            ],
          ),
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
