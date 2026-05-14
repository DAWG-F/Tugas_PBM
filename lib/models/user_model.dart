class UserModel {
  final int id;
  final String name;
  final String username;
  final String className;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.className,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      className: json['class']['name'],
    );
  }
}