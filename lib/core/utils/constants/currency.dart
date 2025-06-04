class Currency {
  static const List<String> availableCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'IDR',
    'SGD',
    'AUD',
    'CAD',
  ];

  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'IDR': 'Rp',
    'SGD': 'S\$',
    'AUD': 'A\$',
    'CAD': 'C\$',
  };

  static String getSymbol(String currencyCode) {
    return currencySymbols[currencyCode] ?? currencyCode;
  }
}
