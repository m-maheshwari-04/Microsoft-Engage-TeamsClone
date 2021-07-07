class UserModel {
  final String uid;
  final String id;
  final String name;
  final String imgUrl;
  final String? token;
  final DateTime? time;
  final List? members;
  UserModel(
      {required this.uid,
      required this.id,
      required this.name,
      required this.imgUrl,
      this.token,
      this.time,
      this.members});
}
