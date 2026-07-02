import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final int id;
  final String name;
  final String email;

  const AppUser({required this.id, required this.name, required this.email});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, email];
}
