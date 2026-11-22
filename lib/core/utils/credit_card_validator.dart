enum CardType { visa, mastercard, amex, discover, unknown }

class CreditCardValidator {
  /// Algoritmo de Luhn (Módulo 10) para validación de número de tarjeta
  static bool isValidLuhn(String cardNumber) {
    final sanitized = cardNumber.replaceAll(RegExp(r'\s+\b|\b\s+|-'), '');
    if (sanitized.length < 13 || sanitized.length > 19) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = sanitized.length - 1; i >= 0; i--) {
      int? digit = int.tryParse(sanitized[i]);
      if (digit == null) return false;

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return (sum % 10 == 0);
  }

  /// Validación de fecha de expiración MM/YY
  static bool isValidExpiryDate(String expiryDate) {
    if (expiryDate.length != 5 || !expiryDate.contains('/')) return false;

    final parts = expiryDate.split('/');
    if (parts.length != 2) return false;

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;

    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;

    if (year < currentYear) return false;
    if (year == currentYear && month < currentMonth) return false;

    return true;
  }

  /// Validación de CVV (3 o 4 dígitos según tipo de tarjeta)
  static bool isValidCVV(String cvv, CardType cardType) {
    final sanitized = cvv.trim();
    if (cardType == CardType.amex) {
      return RegExp(r'^\d{4}$').hasMatch(sanitized);
    }
    return RegExp(r'^\d{3}$').hasMatch(sanitized);
  }

  /// Detección de marca de tarjeta de crédito
  static CardType detectCardType(String cardNumber) {
    final sanitized = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (sanitized.startsWith('4')) {
      return CardType.visa;
    } else if (RegExp(r'^(5[1-5]|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)').hasMatch(sanitized)) {
      return CardType.mastercard;
    } else if (RegExp(r'^(34|37)').hasMatch(sanitized)) {
      return CardType.amex;
    } else if (sanitized.startsWith('6011') || sanitized.startsWith('65')) {
      return CardType.discover;
    }
    return CardType.unknown;
  }

  /// Formatea el número de tarjeta en grupos de 4 dígitos (0000 0000 0000 0000)
  static String formatCardNumber(String input) {
    final sanitized = input.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < sanitized.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(sanitized[i]);
    }
    return buffer.toString();
  }

  /// Enmascara el número dejando solo los últimos 4 dígitos
  static String maskCardNumber(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 4) return clean;
    final last4 = clean.substring(clean.length - 4);
    return '•••• •••• •••• $last4';
  }
}
