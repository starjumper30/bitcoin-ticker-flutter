import 'package:bitcoin_ticker/coin_data_dio_rxdart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class PriceScreen extends StatefulWidget {
  const PriceScreen({Key? key}) : super(key: key);

  @override
  State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  CoinData coinData = CoinData();

  void updateCurrency(String? currency) async {
    coinData.setSelectedCurrency(currency ?? defaultCurrency);
  }

  DropdownButton<String> androidDropdown() {
    return DropdownButton<String>(
      value: coinData.selectedCurrency(),
      items: currenciesList
          .map((currency) => DropdownMenuItem(
                value: currency,
                child: Text(currency),
              ))
          .toList(),
      onChanged: (String? currency) => updateCurrency(currency),
    );
  }

  CupertinoPicker iosPicker() {
    return CupertinoPicker(
        scrollController: FixedExtentScrollController(
            initialItem: currenciesList.indexOf(defaultCurrency)),
        itemExtent: 32.0,
        onSelectedItemChanged: (selectedIndex) =>
            updateCurrency(currenciesList[selectedIndex]),
        children: currenciesList.map((currency) => Text(currency)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          StreamBuilder<List<ExchangeRate>>(
            stream: coinData.rates(),
            builder: (contest, snapshot) {
              List<ExchangeRate> rates = snapshot.hasData
                  ? snapshot.data!
                  : cryptoList
                      .map((crypto) => ExchangeRate(
                          crypto: crypto,
                          currency: coinData.selectedCurrency(),
                          rate: 0))
                      .toList();
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: rates.map((r) => CryptoCard(rate: r)).toList());
            },
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iosPicker() : androidDropdown(),
          ),
        ],
      ),
    );
  }
}

class CryptoCard extends StatelessWidget {
  final ExchangeRate rate;
  const CryptoCard({Key? key, required this.rate}) : super(key: key);

  String getExchangeRateText(ExchangeRate rate) {
    String quote = rate.rate > 0 ? rate.rate.toInt().toString() : '?';
    return '1 ${rate.crypto} = $quote ${rate.currency}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            getExchangeRateText(rate),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
