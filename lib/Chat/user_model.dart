/// Model to keep all user or group chat related info together
class UserModel {
  final String uid;
  final String id;
  final String name;
  final String imgUrl;
  /// fcm token to send notification
  final String? token;
  /// last message time
  final DateTime? time;
  /// Members in group chat
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
