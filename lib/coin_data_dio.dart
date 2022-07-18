import 'package:dio/dio.dart';

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
  CancelToken _cancelToken = CancelToken();

  Future<List<ExchangeRate>> getRates() async {
    Dio dio = Dio();
    _cancelToken.cancel();
    _cancelToken = CancelToken();
    List<ExchangeRate?> rates = [];
    String currency = selectedCurrency;
    try {
      rates = await Future.wait(
          cryptoList.map((crypto) => _getRate(dio, crypto, currency)));
    } finally {
      dio.close();
    }
    return rates.where((rate) => rate != null).map((e) => e!).toList();
  }

  Future<ExchangeRate?> _getRate(
      Dio dio, String crypto, String currency) async {
    try {
      Response response = await dio.get(
        '$coinApi/$crypto/$currency',
        cancelToken: _cancelToken,
        options: Options(headers: {'X-CoinAPI-Key': apiKey}),
      );

      var decodedResponse = response.data;
      return ExchangeRate(
        crypto: decodedResponse['asset_id_base'],
        currency: decodedResponse['asset_id_quote'],
        rate: decodedResponse['rate'],
      );
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        print("cancelled for $currency");
      } else {
        print("error for $currency ${e.response?.statusCode}");
      }
      return null;
    }
  }
}
