String? parseAddToListCommand(String spokenText) {
  final raw = spokenText.trim();
  if (raw.isEmpty) return null;
  final lower = raw.toLowerCase();

  final hasListRef = lower.contains("listeme") || lower.contains("listeye");
  final hasAddVerb = lower.contains("ekle");
  if (!hasListRef || !hasAddVerb) return null;

  final listMatch = RegExp(r"(listeme|listeye)\s+(.+?)\s+ekle").firstMatch(lower);
  final phrase = listMatch?.group(2)?.trim();
  if (phrase == null || phrase.isEmpty) return null;

  return phrase.replaceAll(RegExp(r"\s+"), " ").trim();
}

bool isGoToShoppingListCommand(String spokenText) {
  final lower = spokenText.toLowerCase().trim();
  if (lower.isEmpty) return false;

  // Hem Türkçe karakterli hem arapss karakterli ifadeler için kontrol.
  return lower.contains("alışveriş listesine geç") ||
      lower.contains("alisveris listesine gec") ||
      lower.contains("listeye gec") ||
      lower.contains("listeye geç");
}
