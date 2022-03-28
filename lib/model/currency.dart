import 'package:get/get.dart';

class CurrencyList {
  List<Currency> currencies;

  CurrencyList({required this.currencies});

  factory CurrencyList.fromJson(Map<String, dynamic> json) {
    List<Currency> currencies = [];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        currencies.add(Currency.fromJson(v));
      });
    }
    return CurrencyList(currencies: currencies);
  }
}

class Currency {
  int id;
  String name;
  String symbol;
  Quote quote;
  String avatar;

  Currency(
      {required this.id,
      required this.name,
      required this.symbol,
      required this.quote,
      required this.avatar});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
        id: json['id'],
        name: json['name'],
        symbol: json['symbol'],
        avatar:
            'https://s2.coinmarketcap.com/static/img/coins/64x64/${json['id']}.png',
        quote: Quote.fromJson(json['quote']));
  }
}

class Quote {
  USD uSD;

  Quote({required this.uSD});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(uSD: USD.fromJson(json['USD']));
  }
}

class USD extends GetxController {
  var price = 0.0.obs;
  bool isChanged = false;
  var isIncrement = false.obs;

  USD();

  factory USD.fromJson(Map<String, dynamic> json) {
    return USD()..updatePrice(newPrice: json['price']);
  }

  updatePrice({required double newPrice}) {
    price(newPrice);
  }

  updateIsIncrement({required bool newIncrement}) {
    isIncrement(newIncrement);
  }
}
