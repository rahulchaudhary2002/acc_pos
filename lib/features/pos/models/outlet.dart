import 'json_utils.dart';

class Outlet {
  final int id;
  final int companyId;
  final String name;

  Outlet({required this.id, required this.companyId, required this.name});

  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      id: asInt(json['id']),
      companyId: asInt(json['company_id']),
      name: json['name'] as String,
    );
  }
}
