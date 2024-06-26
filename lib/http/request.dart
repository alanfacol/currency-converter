import 'dart:convert';
import 'package:currency_converter/model/currency.model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CurrencyService {
  final String? baseUrl = dotenv.env['API_URL'];
  final String? apiKey = dotenv.env['API_KEY'];

  CurrencyService();

  Future<Map<String, String>> fetchCurrencies(
      {List<String>? allowedCodes}) async {
    final response = await http
        .get(Uri.https(baseUrl!, '/api/currencies.json', {'app_id': apiKey}));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (allowedCodes != null && allowedCodes.isNotEmpty) {
        data.removeWhere((key, value) => !allowedCodes.contains(key));
      }
      return Map<String, String>.from(data);
    } else {
      throw Exception('Failed to load currency data');
    }
  }

  Future<CurrencyData> fetchRates({required List<String> codes}) async {
    final response = await http.get(Uri.https(baseUrl!, '/api/latest.json',
        {'app_id': apiKey, 'symbols': codes.join(',')}));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, num> filteredRates = {};
      for (var code in codes) {
        if (data['rates'].containsKey(code)) {
          filteredRates[code] = data['rates'][code];
        }
      }
      return CurrencyData(
        timestamp: data['timestamp'],
        base: data['base'],
        rates: filteredRates,
      );
    } else {
      throw Exception('Failed to load rate data');
    }
  }

  Future<CurrencyData> fetchHistorialRates(
      {required List<String> codes, required String date}) async {
    final response = await http.get(Uri.https(
        baseUrl!,
        '/api/historical/$date.json',
        {'app_id': apiKey, 'symbols': codes.join(',')}));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final Map<String, num> filteredRates = {};
      for (var symbol in codes) {
        if (data['rates'].containsKey(symbol)) {
          filteredRates[symbol] = data['rates'][symbol];
        }
      }
      return CurrencyData(
        timestamp: data['timestamp'],
        base: data['base'],
        rates: filteredRates,
      );
    } else {
      throw Exception('Failed to load historical rate data');
    }
  }
}
