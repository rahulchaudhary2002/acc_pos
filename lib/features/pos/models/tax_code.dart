import 'json_utils.dart';

class TaxCode {
  final int id;
  final int companyId;
  final String name;
  final double rate;

  TaxCode({required this.id, required this.companyId, required this.name, required this.rate});

  factory TaxCode.fromJson(Map<String, dynamic> json) {
    return TaxCode(
      id: asInt(json['id']),
      companyId: asInt(json['company_id']),
      name: json['name'] as String,
      rate: double.parse(json['rate'].toString()),
    );
  }
}
