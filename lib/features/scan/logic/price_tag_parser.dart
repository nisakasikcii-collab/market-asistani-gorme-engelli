class PriceParseResult {
  const PriceParseResult({
    this.priceTl,
    this.discountedPriceTl,
  });

  final double? priceTl;
  final double? discountedPriceTl;

  bool get hasAnyPrice => priceTl != null || discountedPriceTl != null;

  String toSpeechText() {
    final main = priceTl;
    final discounted = discountedPriceTl;
    if (main == null && discounted == null) {
      return "Fiyat bilgisi okunamadı.";
    }
    if (main != null && discounted != null) {
      return "Ürün fiyatı ${_formatTl(main)} TL, indirimli fiyat ${_formatTl(discounted)} TL.";
    }
    final single = discounted ?? main!;
    return "Urun fiyati ${_formatTl(single)} TL.";
  }

  static String _formatTl(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2).replaceAll(".", ",");
  }
}

PriceParseResult parsePriceTagFromOcr(String rawText) {
  final normalized = _normalize(rawText);
  if (normalized.isEmpty) {
    return const PriceParseResult();
  }

  final values = _extractValues(normalized);
  if (values.isEmpty) {
    return const PriceParseResult();
  }

  double? discounted;
  for (final line in normalized.split("\n")) {
    if (_looksLikeDiscountLine(line)) {
      final lineValues = _extractValues(line);
      if (lineValues.isNotEmpty) {
        discounted = lineValues.first;
        break;
      }
    }
  }

  double? regular;
  if (discounted != null) {
    regular = values.firstWhere(
      (v) => (v - discounted!).abs() > 0.001,
      orElse: () => discounted!,
    );
  } else {
    regular = values.first;
  }

  if (discounted != null && regular < discounted) {
    final tmp = regular;
    regular = discounted;
    discounted = tmp;
  }

  return PriceParseResult(
    priceTl: regular,
    discountedPriceTl: discounted,
  );
}

String _normalize(String rawText) {
  return rawText
      .replaceAll("\r\n", "\n")
      .replaceAll("₺", " TL ")
      .replaceAll(",", ".")
      .replaceAll(RegExp(r"[ \t]+"), " ")
      .trim();
}

List<double> _extractValues(String text) {
  final results = <double>[];
  final withCurrency = RegExp(
    r"(?:^|[^0-9])([0-9]{1,4}(?:\.[0-9]{1,2})?)\s*(?:TL|TRY)\b",
    caseSensitive: false,
  );
  for (final m in withCurrency.allMatches(text)) {
    final v = double.tryParse(m.group(1)!);
    if (v != null) {
      results.add(v);
    }
  }

  if (results.isNotEmpty) {
    return _distinctSorted(results);
  }

  final fallback = RegExp(r"\b([0-9]{1,4}\.[0-9]{1,2})\b");
  for (final m in fallback.allMatches(text)) {
    final v = double.tryParse(m.group(1)!);
    if (v != null) {
      results.add(v);
    }
  }
  return _distinctSorted(results);
}

List<double> _distinctSorted(List<double> values) {
  final uniq = <double>[];
  for (final value in values) {
    final exists = uniq.any((x) => (x - value).abs() < 0.001);
    if (!exists) {
      uniq.add(value);
    }
  }
  uniq.sort((a, b) => b.compareTo(a));
  return uniq;
}

bool _looksLikeDiscountLine(String line) {
  final lower = line.toLowerCase();
  return lower.contains("indirim") ||
      lower.contains("kampanya") ||
      lower.contains("firsat") ||
      lower.contains("fırsat") ||
      lower.contains("sepette");
}
