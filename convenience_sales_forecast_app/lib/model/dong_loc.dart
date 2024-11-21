class DongLoc {
  String dong;
  double lat;
  double lng;

  DongLoc({
    required this.dong,
    required this.lat,
    required this.lng,
  });

  DongLoc.fromMap(Map<String, dynamic> res)
      : dong = res['행정동'],
        lat = res['lat'],
        lng = res['lng'];
}
