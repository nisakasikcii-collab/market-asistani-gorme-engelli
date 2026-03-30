import "package:eyeshopper_ai/features/scan/logic/price_tag_parser.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("TL formatindan fiyat ve indirimli fiyati parse eder", () {
    const ocr = """
ULKER CIKOLATA
Fiyat 45 TL
Indirimli fiyat 38 TL
""";

    final r = parsePriceTagFromOcr(ocr);
    expect(r.priceTl, 45);
    expect(r.discountedPriceTl, 38);
  });

  test("para birimi sembolu ve virgul ayracini normalize eder", () {
    const ocr = """
Kampanya
Normal: 52,90 ₺
Indirim: 47,50 ₺
""";

    final r = parsePriceTagFromOcr(ocr);
    expect(r.priceTl, 52.9);
    expect(r.discountedPriceTl, 47.5);
  });

  test("tek fiyat varsa yalnizca priceTl dolar", () {
    const ocr = "Etiket: 19.95 TL";
    final r = parsePriceTagFromOcr(ocr);
    expect(r.priceTl, 19.95);
    expect(r.discountedPriceTl, isNull);
  });

  test("TRY para birimini de destekler", () {
    const ocr = """
Normal fiyat: 129.90 TRY
Kampanya: 109.90 TRY
""";
    final r = parsePriceTagFromOcr(ocr);
    expect(r.priceTl, 129.9);
    expect(r.discountedPriceTl, 109.9);
  });

  test("indirim satiri daha yuksekse otomatik duzeltir", () {
    const ocr = """
Indirimli: 62 TL
Fiyat: 55 TL
""";
    final r = parsePriceTagFromOcr(ocr);
    expect(r.priceTl, 62);
    expect(r.discountedPriceTl, 55);
  });

  test("fiyat yoksa bos sonuc doner", () {
    const ocr = "Urun aciklamasi: glutensiz biskuvi";
    final r = parsePriceTagFromOcr(ocr);
    expect(r.hasAnyPrice, isFalse);
    expect(r.toSpeechText(), "Fiyat bilgisi okunamadı.");
  });
}
