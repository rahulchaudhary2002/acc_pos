import 'json_utils.dart';

/// A customer, vendor, or distributor party record.
class Party {
  final int id;
  final String name;
  final String? mobileNo;
  final String? address;
  final String? type;
  final bool isDistributor;
  final int? centralPartyId;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? panVatNo;

  Party({
    required this.id,
    required this.name,
    this.mobileNo,
    this.address,
    this.type,
    this.isDistributor = false,
    this.centralPartyId,
    this.contactPerson,
    this.phone,
    this.email,
    this.panVatNo,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: asInt(json['id']),
      name: json['name'] as String,
      mobileNo: json['mobile_no'] as String?,
      address: json['address'] as String?,
      type: json['type'] as String?,
      isDistributor: json['is_distributor'] == true || json['is_distributor'] == 1 || json['is_distributor'] == '1',
      centralPartyId: asIntOrNull(json['central_party_id']),
      contactPerson: json['contact_person'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      panVatNo: json['pan_vat_no'] as String?,
    );
  }
}
