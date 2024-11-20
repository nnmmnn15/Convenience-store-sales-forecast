import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;

class MapHandler extends GetxController with GetTickerProviderStateMixin {
  final mapController = MapController();

  // 신촌동 중심 좌표
  final shinchonBounds = LatLngBounds(
    const latlng.LatLng(37.55477445764391, 126.9294163813863), // 남서쪽 경계
    const latlng.LatLng(37.57477445764391, 126.9494163813863), // 북동쪽 경계
  );

  // 안암동 좌표
  final anamBounds = LatLngBounds(
    const latlng.LatLng(37.577258701210175, 127.01935259671821), // 남서쪽 경계
    const latlng.LatLng(37.597258701210175, 127.03935259671821), // 북동쪽 경계
  );

  // 현재 행정동 위치
  late LatLngBounds bound;

  // 위치 선택 상태 체크
  final isPicked = false.obs;

  // 상세 보기 상태 체크
  final isDetail = false.obs;
  // 상세 보기 애니메이션
  late AnimationController animationController;
  late Animation<Offset> offsetAnimation;

  // 선택한 위도 경도
  final selectLatLng = const latlng.LatLng(0, 0).obs;

  // 근처 범위
  final rangeList = [50, 100, 150, 200, 250];
  final dropdownValue = 50.obs;

  // 상세 보기 변경 값
  final feature1 = 0.0.obs;
  final feature2 = 0.0.obs;
  final feature3 = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // 초기값 신촌동
    bound = shinchonBounds;
    // 범위 초기값
    dropdownValue.value = rangeList[0];

    // 애니메이션 설정
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    offsetAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // 시작점
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

  // 행정동 변경
  void changeLocate(int num) {
    isPicked.value = false;
    bound = num == 0 ? shinchonBounds : anamBounds;
    mapController.fitCamera(CameraFit.bounds(bounds: bound));
  }

  // 범위 선택
  void setRange(int range) {
    dropdownValue.value = range;
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
    FirebaseFirestore.instance.collection('store_hist').add({
      'email': 'dnjsd99@gmail.com',
      'lat': selectLatLng.value.latitude,
      'lng': selectLatLng.value.longitude,
      'salesResult': 12340000,
      'features': 20
    });
  }
}
