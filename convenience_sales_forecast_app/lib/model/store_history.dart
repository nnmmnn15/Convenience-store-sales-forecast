class StoreHistory {
  // email: "string"
  // lat: "double"
  // lng: "double"
  // sales_result: "int"
  // features: "double"
  String docId;
  String email;
  String alias;
  double lat;
  double lng;
  int salesResult;
  List features;
  String updatetime;

  StoreHistory({
    required this.docId,
    required this.email,
    required this.alias,
    required this.lat,
    required this.lng,
    required this.salesResult,
    required this.features,
    required this.updatetime,
  });

  // 명명된 생성자를 사용하여 Map에서 Feed 객체 생성
  StoreHistory.fromMap(Map<String, dynamic> res, String docId)
      : docId = docId,
        email = res['email'],
        alias = res['alias'],
        lat = res['lat'],
        lng = res['lng'],
        salesResult = res['salesResult'],
        features = res['features'],
        updatetime = res['updatetime'];
}
