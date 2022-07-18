import 'dart:convert';

import 'package:http/http.dart' as http;

const List<String> currenciesList = [
  'AUD',
  'BRL',
  'CAD',
  'CNY',
  'EUR',
  'GBP',
  'HKD',
  'IDR',
  'ILS',
  'INR',
  'JPY',
  'MXN',
  'NOK',
  'NZD',
  'PLN',
  'RON',
  'RUB',
  'SEK',
  'SGD',
  'USD',
  'ZAR'
];

const List<String> cryptoList = [
  'BTC',
  'ETH',
  'LTC',
];

class ExchangeRate {
  String crypto = '';
  String currency = '';
  double rate = 0;

  ExchangeRate(
      {required this.crypto, required this.currency, required this.rate});
}

const String defaultCurrency = 'USD';
const String coinApi = 'https://rest.coinapi.io/v1/exchangerate';
const String apiKey = '';

class CoinData {
  String selectedCurrency = defaultCurrency;

  Future<List<ExchangeRate>> getRates() async {
    List<ExchangeRate?> rates = [];
    String currency = selectedCurrency;
    var client = http.Client();
    try {
      rates = await Future.wait(
          cryptoList.map((crypto) => _getRate(client, crypto, currency)));
    } finally {
      client.close();
    }
    return rates.where((rate) => rate != null).map((e) => e!).toList();
  }

  Future<ExchangeRate?> _getRate(
      http.Client client, String crypto, String currency) async {
    http.Response response = await client.get(
        Uri.parse('$coinApi/$crypto/$currency'),
        headers: {'X-CoinAPI-Key': apiKey});
    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body);
      return ExchangeRate(
        crypto: decodedResponse['asset_id_base'],
        currency: decodedResponse['asset_id_quote'],
        rate: decodedResponse['rate'],
      );
    } else {
      print(response.statusCode);
      return null;
    }
  }
}
