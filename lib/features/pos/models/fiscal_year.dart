import 'json_utils.dart';

class FiscalYear {
  final int id;
  final int companyId;
  final String name;
  final String startDate;
  final String endDate;
  final bool isCurrent;

  FiscalYear({
    required this.id,
    required this.companyId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
  });

  factory FiscalYear.fromJson(Map<String, dynamic> json) {
    final isCurrent = json['is_current'];
    return FiscalYear(
      id: asInt(json['id']),
      companyId: asInt(json['company_id']),
      name: json['name'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      isCurrent: isCurrent == true || isCurrent == 1 || isCurrent == '1',
    );
  }
}
