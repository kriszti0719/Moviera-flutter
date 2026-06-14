class UserModel {
  final String id;
  final String email;

  const UserModel({
    required this.id,
    required this.email,
  });

  /// Factory konstruktor a Firebase User objektum kényelmes konvertálásához
  factory UserModel.fromFirebase(String id, String email) {
    return UserModel(
      id: id,
      email: email,
    );
  }
}