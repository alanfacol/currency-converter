class CurrencyData {
  final num timestamp;
  final String base;
  final Map<String, num> rates;

  CurrencyData(
      {required this.timestamp, required this.base, required this.rates});
}
