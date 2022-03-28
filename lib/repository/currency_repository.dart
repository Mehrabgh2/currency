import 'package:currency/api/get_coins_api.dart';

class CurrencyRepository {
  int _start = 1;

  void getCurrencies(
      {required int count,
      required Function appendPage,
      required Function appendLastPage}) {
    getCoins(start: _start, limit: count).then((value) {
      _start = _start + 20;
      if (value.currencies.length < count) {
        appendLastPage(value.currencies);
      } else {
        appendPage(value.currencies);
      }
    });
  }
}
