import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convenience_sales_forecast_app/model/chart_model.dart';
import 'package:convenience_sales_forecast_app/model/dong_loc.dart';
import 'package:convenience_sales_forecast_app/model/store_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:http/http.dart' as http;

class MapHandler extends GetxController with GetTickerProviderStateMixin {
  final GetStorage box = GetStorage();
  final mapController = MapController();

  // 지도의 실행 상태
  final isRun = false.obs;

  // 시작점
  final latlng.LatLng startPoint =
      const latlng.LatLng(37.56640471391909, 126.97804621813793);
  // late LatLngBounds bound;

  // 위치 선택 상태 체크
  final isPicked = false.obs;

  // 상세 보기 상태 체크
  final isDetail = false.obs;
  // 상세 보기 애니메이션
  late AnimationController animationController;
  late Animation<Offset> offsetAnimation;

  // 상세 보기 변경 값
  final peoplesList = <int>[0, 0, 0, 0, 0].obs;
  final feature1 = <double>[100, 100, 100, 100, 100].obs;

  // 이름 입력 텍스트 필드
  final TextEditingController textEditingController = TextEditingController();

  // 선택한 위도 경도
  final selectLatLng = const latlng.LatLng(0, 0).obs;

  // 행정동
  final dongInfo = <DongLoc>[].obs;
  final dongNames = ['로딩'].obs;
  final dropdownValue = '로딩'.obs;

  // 행정동 폴리곤
  final dongPolygon =
      <latlng.LatLng>[const latlng.LatLng(1, 1), const latlng.LatLng(0, 0)].obs;

  // 선택한 동이름
  final selectDongName = "".obs;
  // 해당 동의 편의점 수
  final storeCount = 0.obs;
  // 해당 동의 예상 매출
  final salesForecast = 0.obs;

  final otherPlaceSales = <ChartModel>[].obs;

  // Firebase
  final locInfo = FirebaseFirestore.instance.collection('loc');
  final history = FirebaseFirestore.instance.collection('store_hist');

  // 저장 기록 리스트
  final histList = <StoreHistory>[].obs;

  // 선택한 기록의 index
  final RxInt selectedIndex = (-1).obs;
  // 선택 상태 체크
  final selectedStore = false.obs;

  // API URL
  final String defaultUrl = "http://127.0.0.1:8000";

  @override
  void onInit() {
    super.onInit();

    // 행정동 이름 가져오기
    getLoc();

    // 저장 내역 불러오기
    getHistory();

    // 애니메이션 설정
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // 시작점
      end: Offset.zero, // 종료점
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
    // isDetail의 값이 변할때 마다 실행
    ever(isDetail, (bool showDetail) {
      if (showDetail) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  void getLoc() async {
    final querySnapshot = await locInfo.get();
    dongInfo.value = querySnapshot.docs
        .map(
          (doc) => DongLoc.fromMap(doc.data()),
        )
        .toList();
    dongNames.value = dongInfo.map((dong) => dong.dong).toList();
    dropdownValue.value = dongNames[0];
  }

  // 행정동 변경
  void changeLocate(String dong) {
    isPicked.value = false;
    dropdownValue.value = dong;
    final selecetDong = dongInfo.where((doc) => doc.dong == dong).toList();
    mapController.move(
      latlng.LatLng(selecetDong[0].lat, selecetDong[0].lng),
      16,
    );
  }

  // 지도의 한 지점을 선택
  Future<void> selectPoint(double lat, double lng) async {
    isPicked.value = true;
    selectLatLng.value = latlng.LatLng(lat, lng);
    await getPolygon();
    await getDongName();
    await getStoreCount();
    await forecast();
    // isPicked.value = !isPicked.value;
    // * 예상 매출액을 불러오는 코드 api * //
    // if (isPicked.value) {}
  }

  // polygon
  Future<void> getPolygon() async {
    var url = Uri.parse(
        "$defaultUrl/dong_polygon?lat=${selectLatLng.value.latitude}&lng=${selectLatLng.value.longitude}");
    final response = await http.get(url); // GET 요청
    if (response.statusCode == 200) {
      // 성공적으로 응답을 받았을 때
      final data = json.decode(response.body);
      final latlngList = data['message'];
      dongPolygon.value =
          (latlngList.map((p) => latlng.LatLng(p[1], p[0])).toList())
              .cast<latlng.LatLng>();
    }
  }

  resetPolygon() {
    dongPolygon.value = [const latlng.LatLng(1, 1), const latlng.LatLng(0, 0)];
  }

  // 행정동의 편의점 수
  Future<void> getStoreCount() async {
    var url = Uri.parse(
        "$defaultUrl/store_count?lat=${selectLatLng.value.latitude}&lng=${selectLatLng.value.longitude}");
    final response = await http.get(url); // GET 요청
    if (response.statusCode == 200) {
      // 성공적으로 응답을 받았을 때
      String decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      storeCount.value = data['message'];
    }
  }

  // 행정동 이름
  Future<void> getDongName() async {
    var url = Uri.parse(
        "$defaultUrl/dong_name?lat=${selectLatLng.value.latitude}&lng=${selectLatLng.value.longitude}");
    final response = await http.get(url); // GET 요청
    if (response.statusCode == 200) {
      // 성공적으로 응답을 받았을 때
      String decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      selectDongName.value = data['message'];
    }
  }

  // 매출 예측
  Future<void> forecast() async {
    var url = (isDetail.value || selectedStore.value)
        ? Uri.parse(
            "$defaultUrl/calculate?teen=${feature1[0] / 100}&twen=${feature1[1] / 100}&thirty=${feature1[2] / 100}&forty=${feature1[3] / 100}&fifty=${feature1[4] / 100}&lat=${selectLatLng.value.latitude}&lng=${selectLatLng.value.longitude}")
        : Uri.parse(
            "$defaultUrl/calculate?lat=${selectLatLng.value.latitude}&lng=${selectLatLng.value.longitude}");
    final response = await http.get(url); // GET 요청
    if (response.statusCode == 200) {
      // 성공적으로 응답을 받았을 때
      String decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      salesForecast.value = data['message'];
      peoplesList.value = (data['pops'] as List<dynamic>).cast<int>();
    }
  }

  // 타지역 매출 예측
  // gpt
  Future<void> otherForecast() async {
    var url = Uri.parse(
        "$defaultUrl/other_place?teen=${feature1[0] / 100}&twen=${feature1[1] / 100}&thirty=${feature1[2] / 100}&forty=${feature1[3] / 100}&fifty=${feature1[4] / 100}&dong=${selectDongName.value}");
    final response = await http.get(url); // GET 요청
    if (response.statusCode == 200) { 
      // 성공적으로 응답을 받았을 때
      String decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      final otherSale = data['message'];
      otherPlaceSales.value =
          otherSale.map<ChartModel>((info) => ChartModel(info[0], info[1])).toList();

      otherPlaceSales.sort((a, b) => (a.value - salesForecast.value)
          .abs()
          .compareTo((b.value - salesForecast.value).abs()));

      // 상위 5개 항목만 유지
      otherPlaceSales.value = otherPlaceSales.take(5).toList();
    }
  }


  // otherForecast() async {
  //   var url = Uri.parse(
  //       "$defaultUrl/other_place?teen=${feature1[0] / 100}&twen=${feature1[1] / 100}&thirty=${feature1[2] / 100}&forty=${feature1[3] / 100}&fifty=${feature1[4] / 100}&dong=${selectDongName.value}");
  //   final response = await http.get(url); // GET 요청
  //   if (response.statusCode == 200) {
  //     // 성공적으로 응답을 받았을 때
  //     String decodedBody = utf8.decode(response.bodyBytes);
  //     final data = json.decode(decodedBody);
  //     final otherSale = data['message'];
  //     otherPlaceSales.value =
  //         otherSale.map((info) => ChartModel(info[0], info[1])).toList();

  //     otherPlaceSales.sort((a, b) => (a.value - salesForecast.value)
  //         .abs()
  //         .compareTo((b.value - salesForecast.value).abs()));

  //     // 상위 5개 항목만 반환
  //     otherPlaceSales.value = otherPlaceSales.take(5).toList();
  //     // print(otherPlaceSales.whereType<int>().toList());
  //   }
  // }

  // 매출 표기
  String wirteSale(sale) {
    // 숫자를 문자열로 변환 후 뒤에서부터 쉼표 추가
    String formatted = sale.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (Match match) => '${match[1]},');
    return formatted;
  }

  // 이전 분기 유동인구 수
  Future<void> footTraffic() async {
    var url = Uri.parse(
        "$defaultUrl/people_count?lat=${selectLatLng.value.latitude}&lng=${selectLatLng.value.longitude}");
    final response = await http.get(url); // GET 요청
    if (response.statusCode == 200) {
      // 성공적으로 응답을 받았을 때
      String decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      peoplesList.value = (data['pops'] as List<dynamic>).cast<int>();
    }
  }

  detailStateSwitch() {
    isDetail.value = !isDetail.value;
  }

  // 선택한 위치의 매장 정보 저장
  void saveStoreInf() {
    // email: "string"
    // lat: "double"
    // lng: "double"
    // sales_result: "int"
    // features: "double"
    DateTime now = DateTime.now();
    // !! 이메일, 매출 예측값,
    history.add({
      'email': box.read('userEmail'),
      'alias': textEditingController.text,
      'lat': selectLatLng.value.latitude,
      'lng': selectLatLng.value.longitude,
      'salesResult': salesForecast.value,
      'features': feature1,
      'updatetime': now.toString(),
    });
  }

  void getHistory() {
    history
        .where('email', isEqualTo: box.read('userEmail')) // !! 조건 변경
        .orderBy('updatetime', descending: true) // 정렬 updatetime의 역순(내림차순)
        .snapshots()
        .listen((event) {
      histList.value = event.docs
          .map(
            (doc) => StoreHistory.fromMap(doc.data(), doc.id),
          )
          .toList();
    });
  }

  void updateHistory(StoreHistory storeInfo) async {
    await forecast();
    history.doc(storeInfo.docId).set({
      'email': storeInfo.email,
      'alias': storeInfo.alias,
      'lat': storeInfo.lat,
      'lng': storeInfo.lng,
      'salesResult': salesForecast.value,
      'features': feature1,
      'updatetime': storeInfo.updatetime,
    });
  }
}
