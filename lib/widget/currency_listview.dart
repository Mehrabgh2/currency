import 'dart:convert';

import 'package:currency/model/currency.dart';
import 'package:currency/model/realtime_currency.dart';
import 'package:currency/repository/currency_repository.dart';
import 'package:currency/widget/currency_row.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CurrencyListView extends StatelessWidget {
  int _pageSize = 20;
  PagingController<int, CurrencyRow> controller =
      PagingController<int, CurrencyRow>(firstPageKey: 1);
  CurrencyRepository repo = CurrencyRepository();
  List<String> showedCoins = [];
  WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse("wss://ws-feed.pro.coinbase.com"));

  @override
  Widget build(BuildContext context) {
    controller.addPageRequestListener((pageKey) {
      repo.getCurrencies(
          count: 20, appendPage: appendPage, appendLastPage: appendLastPage);
    });
    channel.stream.listen(
        (event) {
          RealtimeCurrency ev =
              RealtimeCurrency.fromJson(jsonDecode(event.toString()));
          CurrencyRow row = controller.itemList!.firstWhere((element) =>
              ev.productId.substring(0, ev.productId.length - 4) ==
              element.currency.symbol);
          row.updatePrice(newPrice: double.parse(ev.price));
        },
        onDone: () {},
        onError: (err) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error ${err.toString()}"),
          ));
        });
    return OrientationBuilder(builder: (context, orientation) {
      return Column(
        children: [
          Expanded(
            child: PagedGridView<int, CurrencyRow>(
              pagingController: controller,
              showNewPageProgressIndicatorAsGridChild: false,
              showNewPageErrorIndicatorAsGridChild: false,
              showNoMoreItemsIndicatorAsGridChild: false,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: orientation == Orientation.portrait ? 1 : 2,
              ),
              builderDelegate: PagedChildBuilderDelegate<CurrencyRow>(
                  itemBuilder: (context, item, index) {
                return CurrencyRow(
                  currency: item.currency,
                );
              }),
            ),
          )
        ],
      );
    });
  }

  void appendPage(List<Currency> items) {
    _pageSize += items.length;
    List<CurrencyRow> widgetItems = List.generate(
        items.length, (index) => CurrencyRow(currency: items[index]));
    controller.appendPage(widgetItems, _pageSize);
    for (Currency item in items) {
      showedCoins.add("${item.symbol.toUpperCase()}-USD");
    }
    setCoinsToListen();
  }

  void appendLastPage(List<Currency> items) {
    _pageSize += items.length;
    List<CurrencyRow> widgetItems = List.generate(
        items.length, (index) => CurrencyRow(currency: items[index]));
    controller.appendLastPage(widgetItems);
    for (Currency item in items) {
      showedCoins.add("${item.symbol.toUpperCase()}-USD");
    }
    setCoinsToListen();
  }

  void setCoinsToListen() {
    channel.sink.add(jsonEncode({
      "type": "subscribe",
      "channels": [
        {"name": "ticker", "product_ids": showedCoins}
      ]
    }));
  }

  void retryConnect(BuildContext context) {
    channel =
        WebSocketChannel.connect(Uri.parse("wss://ws-feed.pro.coinbase.com"));
    channel.sink.add(jsonEncode({
      "type": "subscribe",
      "channels": [
        {"name": "ticker", "product_ids": showedCoins}
      ]
    }));
    channel.stream.listen(
        (event) {
          RealtimeCurrency ev =
              RealtimeCurrency.fromJson(jsonDecode(event.toString()));
          CurrencyRow row = controller.itemList!.firstWhere((element) =>
              ev.productId.substring(0, ev.productId.length - 4) ==
              element.currency.symbol);
          row.updatePrice(newPrice: double.parse(ev.price));
        },
        onDone: () {},
        onError: (err) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error ${err.toString()}"),
          ));
        });
  }

  void dispose() {
    channel.sink.close();
  }
}
