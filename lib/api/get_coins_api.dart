import 'dart:convert';

import 'package:currency/model/currency.dart';
import 'package:http/http.dart' as http;

Future<CurrencyList> getCoins({required int start, required int limit}) async {
  try {
    final response = await http.get(Uri.parse(
        'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?start=$start&limit=$limit&convert=USD&CMC_PRO_API_KEY=95e05d98-8569-4293-9eaf-cfbbb64a2cd2'));
    if (response.statusCode == 200) {
      return CurrencyList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('failed to load data');
    }
  } catch (ex) {
    throw Exception(ex);
  }
}
