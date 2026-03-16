import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class MLKitService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      await _textRecognizer.close();
      
      return recognizedText.text;
    } catch (e) {
      await _textRecognizer.close();
      throw Exception('Failed to extract text from image: $e');
    }
  }

  // ── Exchange rates to THB (approximate fixed rates) ──────────────────
  static const Map<String, double> _toThbRates = {
    'USD': 36.0,   // US Dollar
    'EUR': 39.0,   // Euro
    'GBP': 46.0,   // British Pound
    'JPY': 0.24,   // Japanese Yen
    'CNY': 5.0,    // Chinese Yuan
    'SGD': 27.0,   // Singapore Dollar
    'MYR': 8.0,    // Malaysian Ringgit
    'KRW': 0.027,  // Korean Won
    'HKD': 4.6,    // Hong Kong Dollar
    'AUD': 24.0,   // Australian Dollar
    'THB': 1.0,    // Thai Baht (no conversion)
  };

  // ── Detect currency from full receipt text ─────────────────────────
  String _detectCurrency(String text) {
    final upper = text.toUpperCase();
    // Check explicit currency codes first
    if (upper.contains('USD') || upper.contains('US DOLLAR')) return 'USD';
    if (upper.contains('EUR') || upper.contains('EURO')) return 'EUR';
    if (upper.contains('GBP') || upper.contains('POUND')) return 'GBP';
    if (upper.contains('JPY') || upper.contains('YEN') || upper.contains('¥')) return 'JPY';
    if (upper.contains('CNY') || upper.contains('RMB') || upper.contains('YUAN')) return 'CNY';
    if (upper.contains('SGD')) return 'SGD';
    if (upper.contains('MYR') || upper.contains('RINGGIT')) return 'MYR';
    if (upper.contains('KRW') || upper.contains('WON') || upper.contains('₩')) return 'KRW';
    if (upper.contains('HKD')) return 'HKD';
    if (upper.contains('AUD')) return 'AUD';
    if (upper.contains('THB') || upper.contains('฿') || upper.contains('BAHT')) return 'THB';
    // Symbol fallback
    if (text.contains('\$')) return 'USD';
    if (text.contains('€')) return 'EUR';
    if (text.contains('£')) return 'GBP';
    return 'USD'; // default — assume USD when no symbol detected
  }

  // ── Convert any amount to THB ──────────────────────────────────────
  double _toThb(double amount, String currency) {
    final rate = _toThbRates[currency] ?? 1.0;
    return double.parse((amount * rate).toStringAsFixed(2));
  }

  Future<Map<String, dynamic>> parseReceiptData(String extractedText) async {
    final lines = extractedText.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();

    final detectedCurrency = _detectCurrency(extractedText);
    String? merchantName;
    List<String> items = [];

    // ── Total-first detection: look for explicit total lines first ───────
    double? totalAmount;

    // Keywords that indicate a total line
    final totalKeywords = [
      'total', 'grand total', 'amount due', 'to pay', 'subtotal', 'net total',
      'sum', 'total amount', 'payment', 'balance due', 'due', 'pay',
    ];

    // First pass: only look for lines with total keywords AND currency
    for (final line in lines) {
      if (line.isEmpty) continue;
      final hasTotalKeyword = totalKeywords.any((kw) => line.toLowerCase().contains(kw));
      if (!hasTotalKeyword) continue;

      // Must have currency symbol or decimal cents
      final amountMatch = RegExp(
              r'[\$€£¥₩฿]\s*(\d{1,3}(?:[,\s]?\d{3})*(?:\.\d{2})?)|(\d{1,3}(?:[,\s]?\d{3})*\.\d{2})')
          .firstMatch(line);
      if (amountMatch != null) {
        final raw = (amountMatch.group(1) ?? amountMatch.group(2));
        if (raw == null || raw.isEmpty) continue;
        final clean = raw.replaceAll(RegExp(r'[^\d.]'), '').replaceAll(',', '.');
        if (clean.isEmpty) continue;
        try {
          final value = double.parse(clean);
          if (value >= 0.01 && value <= 9999.99) {
            totalAmount = value;
            break; // found a total line, stop searching
          }
        } catch (_) {}
      }
    }

    // Second pass: if no total found, look for the largest amount with cents
    if (totalAmount == null) {
      double largestAmount = 0;
      for (final line in lines) {
        if (line.isEmpty) continue;
        // Skip lines that look like item quantities or dates
        if (RegExp(r'\b\d{1,3}\s*(?:x|@|qty|item|pc|pcs)\b', caseSensitive: false).hasMatch(line)) continue;
        if (RegExp(r'\d{1,2}:\d{2}').hasMatch(line)) continue; // time
        if (RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}').hasMatch(line)) continue; // date

        final amountMatch = RegExp(
                r'[\$€£¥₩฿]\s*(\d{1,3}(?:[,\s]?\d{3})*(?:\.\d{2})?)|(\d{1,3}(?:[,\s]?\d{3})*\.\d{2})')
            .firstMatch(line);
        if (amountMatch != null) {
          final raw = (amountMatch.group(1) ?? amountMatch.group(2));
          if (raw == null || raw.isEmpty) continue;
          final clean = raw.replaceAll(RegExp(r'[^\d.]'), '').replaceAll(',', '.');
          if (clean.isEmpty) continue;
          try {
            final value = double.parse(clean);
            if (value >= 0.01 && value <= 9999.99 && value > largestAmount) {
              largestAmount = value;
            }
          } catch (_) {}
        }
      }
      if (largestAmount > 0) totalAmount = largestAmount;
    }

    // Extract merchant name and items (unchanged)
    for (final line in lines) {
      if (merchantName == null && _isLikelyMerchantName(line)) {
        merchantName = line;
      }
      if (_isLikelyItem(line)) {
        items.add(line);
      }
    }

    final amountInThb = totalAmount != null ? _toThb(totalAmount, detectedCurrency) : null;

    return {
      'totalAmount': amountInThb,          // always THB
      'originalAmount': totalAmount,        // original value from receipt
      'detectedCurrency': detectedCurrency, // e.g. "USD"
      'merchantName': merchantName ?? 'Unknown Merchant',
      'items': items,
      'rawText': extractedText,
    };
  }

  bool _isLikelyMerchantName(String line) {
    // Skip lines that are clearly amounts, dates, or totals
    if (RegExp(r'[\d,.]+').hasMatch(line) && 
        (line.toLowerCase().contains('total') || 
         line.toLowerCase().contains('amount') ||
         line.toLowerCase().contains('sum'))) {
      return false;
    }
    
    // Skip very short lines or lines with only numbers/symbols
    if (line.length < 3 || RegExp(r'^[\d\s\-\.,\$€£฿]+$').hasMatch(line)) {
      return false;
    }
    
    // Skip common keywords that aren't merchant names
    final skipKeywords = [
      'total', 'subtotal', 'tax', 'vat', 'cash', 'credit', 'debit',
      'change', 'receipt', 'invoice', 'bill', 'amount', 'qty', 'price'
    ];
    
    if (skipKeywords.any((keyword) => line.toLowerCase().contains(keyword))) {
      return false;
    }
    
    return true;
  }

  bool _isLikelyItem(String line) {
    // Skip if it looks like a total or summary line
    if (line.toLowerCase().contains('total') || 
        line.toLowerCase().contains('subtotal') ||
        line.toLowerCase().contains('tax') ||
        line.toLowerCase().contains('vat')) {
      return false;
    }
    
    // Skip if it doesn't contain any numbers (most items have prices)
    if (!RegExp(r'\d').hasMatch(line)) {
      return false;
    }
    
    // Skip if it's just a number or currency
    if (RegExp(r'^[\d\s\-\.,\$€£฿]+$').hasMatch(line)) {
      return false;
    }
    
    return true;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
