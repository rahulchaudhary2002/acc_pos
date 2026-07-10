import 'json_utils.dart';

class Company {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? panVatNo;

  Company({required this.id, required this.name, this.address, this.phone, this.panVatNo});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: asInt(json['id']),
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      panVatNo: json['pan_vat_no'] as String?,
    );
  }
}
