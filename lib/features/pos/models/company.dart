import 'json_utils.dart';

class Company {
  final int id;
  final String name;

  Company({required this.id, required this.name});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(id: asInt(json['id']), name: json['name'] as String);
  }
}
