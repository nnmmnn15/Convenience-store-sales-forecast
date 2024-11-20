class Users {
  String name;
  String email;
  String image;

  Users({
    required this.email,
    required this.image,
    required this.name
  });
  factory Users.fromMap(Map<String, dynamic> map, String id) {
    return Users(
      email: map['email'] ?? '',
      image: map['image'],
      name: map['name']
    );
  }
}
