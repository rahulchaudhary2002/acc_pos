/// Uniform error shape surfaced to providers/UI, mapped from Laravel's
/// `{message, errors: {field: [...]}}` (422 validation) or `{message}`
/// (business-rule errors) responses.
class ApiException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;
  final int? statusCode;

  ApiException({required this.message, this.fieldErrors, this.statusCode});

  /// First error message for a given field, if any (for inline form errors).
  String? errorFor(String field) => fieldErrors?[field]?.first;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
