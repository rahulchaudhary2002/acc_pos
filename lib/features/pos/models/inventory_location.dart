import 'json_utils.dart';

class InventoryLocation {
  final int id;
  final int outletId;
  final int companyId;
  final String name;

  InventoryLocation({
    required this.id,
    required this.outletId,
    required this.companyId,
    required this.name,
  });

  factory InventoryLocation.fromJson(Map<String, dynamic> json) {
    // `/admin/inventory-locations` rows carry the company through the nested
    // `outlet` relation instead of a flat company_id column.
    final outlet = json['outlet'] as Map<String, dynamic>?;
    return InventoryLocation(
      id: asInt(json['id']),
      outletId: asInt(json['outlet_id']),
      companyId: asInt(json['company_id'] ?? outlet?['company_id']),
      name: json['name'] as String,
    );
  }
}
