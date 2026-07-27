import 'json_utils.dart';

/// A row from `GET /admin/reports/vendor-ledger` or `customer-ledger` —
/// one summary line per party for the selected date range. `openingBalance`
/// is only present when a `from_date` filter was supplied to the endpoint.
class PartyLedgerRow {
  final int partyId;
  final String name;
  final String? type;
  final double? openingBalance;
  final double totalDebit;
  final double totalCredit;
  final double balance;

  PartyLedgerRow({
    required this.partyId,
    required this.name,
    this.type,
    this.openingBalance,
    required this.totalDebit,
    required this.totalCredit,
    required this.balance,
  });

  factory PartyLedgerRow.fromJson(Map<String, dynamic> json) {
    return PartyLedgerRow(
      partyId: asInt(json['party_id']),
      name: json['name'] as String? ?? '-',
      type: json['type'] as String?,
      openingBalance: asDoubleOrNull(json['opening_balance']),
      totalDebit: asDoubleOrNull(json['total_debit']) ?? 0,
      totalCredit: asDoubleOrNull(json['total_credit']) ?? 0,
      balance: asDoubleOrNull(json['balance']) ?? 0,
    );
  }
}
