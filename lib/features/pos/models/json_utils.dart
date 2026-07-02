/// Laravel/PHP's PDO driver returns numeric columns as strings on some
/// server configs (observed: production returns `"company_id": "1"`) and as
/// native ints on others (local Docker returns `"company_id": 1`) — same
/// codebase, different MySQL/PDO driver settings per environment. A plain
/// `json['x'] as int` throws on the string form, silently aborting whatever
/// provider called it (the error isn't an ApiException, so it isn't caught
/// or surfaced — the screen just never gets data). Every POS model parses
/// ids through these helpers instead of a raw cast.
int asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.parse(value);
  throw FormatException('Expected an int-like value, got $value (${value.runtimeType})');
}

int? asIntOrNull(dynamic value) {
  if (value == null) return null;
  return asInt(value);
}
