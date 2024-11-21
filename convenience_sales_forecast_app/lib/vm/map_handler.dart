import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convenience_sales_forecast_app/model/dong_loc.dart';
import 'package:convenience_sales_forecast_app/model/store_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MapHandler extends GetxController with GetTickerProviderStateMixin {
  final GetStorage box = GetStorage();
  final mapController = MapController();

  // 지도의 실행 상태
  final isRun = false.obs;

  // 신촌동 중심 좌표
  // final shinchonBounds = LatLngBounds(
  //   const latlng.LatLng(37.55477445764391, 126.9294163813863), // 남서쪽 경계
  //   const latlng.LatLng(37.57477445764391, 126.9494163813863), // 북동쪽 경계
  // );

  // // 안암동 좌표
  // final anamBounds = LatLngBounds(
  //   const latlng.LatLng(37.577258701210175, 127.01935259671821), // 남서쪽 경계
  //   const latlng.LatLng(37.597258701210175, 127.03935259671821), // 북동쪽 경계
  // );

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
  final feature1 = 0.0.obs;
  final feature2 = 0.0.obs;
  final feature3 = 0.0.obs;

  // 이름 입력 텍스트 필드
  final TextEditingController textEditingController = TextEditingController();

  // 선택한 위도 경도
  final selectLatLng = const latlng.LatLng(0, 0).obs;

  // 행정동
  final dongInfo = <DongLoc>[].obs;
  final dongNames = ['로딩'].obs;
  final dropdownValue = '로딩'.obs;

  // Firebase
  final locInfo = FirebaseFirestore.instance.collection('loc');
  final history = FirebaseFirestore.instance.collection('store_hist');

  // 저장 기록 리스트
  final histList = <StoreHistory>[].obs;

  // 선택한 기록의 index
  final RxInt selectedIndex = (-1).obs;
  // 선택 상태 체크
  final selectedStore = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 초기값 신촌동
    // bound = shinchonBounds;

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
  void selectPoint(double lat, double lng) {
    isPicked.value = !isPicked.value;
    selectLatLng.value = latlng.LatLng(lat, lng);
    // * 예상 매출액을 불러오는 코드 api * //
  }

  void getStoresNearCount() {
    // * 근처 매장수를 불러오는 코드 api * //
  }

  void detailStateSwitch() {
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
      'salesResult': 12340000,
      'features': feature1.toInt(),
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

  void updateHistory(StoreHistory storeInfo) {
    history.doc(storeInfo.docId).set({
      'email': storeInfo.email,
      'alias': storeInfo.alias,
      'lat': storeInfo.lat,
      'lng': storeInfo.lng,
      'salesResult': storeInfo.salesResult,
      'features': feature1.value.toInt(),
      'updatetime': storeInfo.updatetime,
    });
  }
}
