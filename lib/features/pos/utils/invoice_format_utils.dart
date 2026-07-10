/// Dart ports of the invoice-formatting helpers in `PosTerminal.jsx`:
/// amount-to-words, the AD→BS (Nepali/Bikram Sambat) date conversion, and
/// the print date/time label — so the mobile tax invoice reproduces the web
/// receipt's "Rupees ... Only" and Nepali-date lines exactly.
library;

const _belowHundred = [
  'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
  'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen',
];
const _tensWords = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

String _belowThousandWords(int part) {
  final words = <String>[];
  final hundreds = part ~/ 100;
  final rest = part % 100;
  if (hundreds > 0) words.add('${_belowHundred[hundreds]} Hundred');
  if (rest > 0) {
    if (rest < 20) {
      words.add(_belowHundred[rest]);
    } else {
      final tens = rest ~/ 10;
      final ones = rest % 10;
      words.add([_tensWords[tens], if (ones > 0) _belowHundred[ones]].join(' ').trim());
    }
  }
  return words.join(' ');
}

/// Indian numbering (Crore/Lakh/Thousand/Hundred) word conversion.
String numberToWords(int number) {
  if (number == 0) return 'Zero';
  const groups = [(10000000, 'Crore'), (100000, 'Lakh'), (1000, 'Thousand'), (100, 'Hundred')];
  var remaining = number;
  final words = <String>[];
  for (final (value, label) in groups) {
    final count = remaining ~/ value;
    if (count == 0) continue;
    words.add('${numberToWords(count)} $label');
    remaining %= value;
  }
  if (remaining > 0) words.add(_belowThousandWords(remaining));
  return words.join(' ');
}

/// e.g. `1234.5` -> `"Rupees One Thousand Two Hundred Thirty Four and Paisa Fifty Only"`.
String amountToWords(double amount) {
  final normalized = amount < 0 ? 0.0 : amount;
  var rupees = normalized.truncate();
  var paisa = ((normalized - rupees) * 100).round();
  if (paisa >= 100) {
    rupees += 1;
    paisa = 0;
  }
  final paisaWords = paisa > 0 ? ' and Paisa ${numberToWords(paisa)}' : '';
  return 'Rupees ${numberToWords(rupees)}$paisaWords Only';
}

/// `DD/MM/YYYY, HH:mm` (en-GB style), matching `getPrintDateTimeLabel`.
String printDateTimeLabel(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  final hour24 = date.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final period = hour24 < 12 ? 'am' : 'pm';
  return '${two(date.day)}/${two(date.month)}/${date.year} $hour12:${two(date.minute)}$period';
}

// --- Bikram Sambat (Nepali) date conversion, ported from
// resources/js/shared/utils/{dateUtils,nepaliDateData}.js ---

const _bsMonthData = <int, List<int>>{
  2050: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2051: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2052: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2053: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2054: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2055: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2056: [31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30],
  2057: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2058: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2059: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2060: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2061: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2062: [30, 32, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31],
  2063: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2064: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2065: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2066: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31],
  2067: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2068: [31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2069: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2070: [31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30],
  2071: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2072: [31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30],
  2073: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31],
  2074: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2075: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2076: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2077: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2078: [31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30],
  2079: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2080: [31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30],
  2081: [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
  2082: [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30],
  2083: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30],
  2084: [31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30],
  2085: [31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 30, 30],
  2086: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
  2087: [31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 30, 30],
  2088: [30, 31, 32, 32, 30, 31, 30, 30, 29, 30, 30, 30],
  2089: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
  2090: [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30],
};

const _bsSupportedYearMax = 2090;
final _bsEpoch = DateTime.utc(1993, 4, 13);
const _bsEpochYear = 2050, _bsEpochMonth = 1, _bsEpochDay = 1;

int? _daysInBsMonth(int year, int month) {
  final months = _bsMonthData[year];
  if (months == null || month < 1 || month > 12) return null;
  return months[month - 1];
}

/// AD `date` -> `"DD/MM/YYYY BS"`, or `""` if outside the supported BS range.
String nepaliDateLabel(DateTime date) {
  final target = DateTime.utc(date.year, date.month, date.day, 12);
  var remainingDays = target.difference(_bsEpoch).inDays;
  if (remainingDays < 0) return '';

  var year = _bsEpochYear, month = _bsEpochMonth, day = _bsEpochDay;
  while (remainingDays > 0) {
    day += 1;
    final monthDays = _daysInBsMonth(year, month);
    if (monthDays == null) return '';
    if (day > monthDays) {
      day = 1;
      month += 1;
      if (month > 12) {
        month = 1;
        year += 1;
        if (year > _bsSupportedYearMax) return '';
      }
    }
    remainingDays -= 1;
  }

  final dd = day.toString().padLeft(2, '0');
  final mm = month.toString().padLeft(2, '0');
  return '$dd/$mm/$year BS';
}

/// Taxable/non-taxable split + VAT rate label, ported from
/// `PosTerminal.jsx`'s `buildTaxSummary` (discount is always 0 there too —
/// the mobile POS one-shot endpoints don't support a cart-level discount).
class InvoiceTaxSummary {
  final double taxable;
  final double nonTaxable;
  final String vatRateLabel;

  const InvoiceTaxSummary({required this.taxable, required this.nonTaxable, required this.vatRateLabel});
}

InvoiceTaxSummary computeTaxSummary(Iterable<(double taxRate, double lineTotal)> lines) {
  var taxable = 0.0, nonTaxable = 0.0;
  final rates = <String>{};
  for (final (taxRate, lineTotal) in lines) {
    if (taxRate > 0) {
      taxable += lineTotal;
      rates.add(_trimTrailingZeroRate(taxRate));
    } else {
      nonTaxable += lineTotal;
    }
  }
  return InvoiceTaxSummary(taxable: taxable, nonTaxable: nonTaxable, vatRateLabel: rates.length == 1 ? '${rates.first} %' : '');
}

String _trimTrailingZeroRate(double rate) {
  final formatted = rate.toStringAsFixed(2);
  return formatted.endsWith('.00') ? formatted.substring(0, formatted.length - 3) : formatted;
}
