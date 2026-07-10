import 'json_utils.dart';

class Outlet {
  final int id;
  final int companyId;
  final String name;
  final String? code;
  final String? address;

  Outlet({required this.id, required this.companyId, required this.name, this.code, this.address});

  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      id: asInt(json['id']),
      companyId: asInt(json['company_id']),
      name: json['name'] as String,
      code: json['code'] as String?,
      address: json['address'] as String?,
    );
  }
}
