import 'package:currency/model/currency.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CurrencyRow extends StatelessWidget {
  Currency currency;
  CurrencyRow({required this.currency});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(currency.avatar),
          ),
          title: Text(
            currency.name,
            style: const TextStyle(color: Colors.black),
          ),
          trailing: Text(
            "\$ ${currency.quote.uSD.price.value.toStringAsFixed(3)}",
            style: TextStyle(color: currency.quote.uSD.isChanged ? currency.quote.uSD.isIncrement.value ? Colors.green : Colors.red : Colors.black),
          ),
        );
      },
    );
  }

  updatePrice({required double newPrice}) {
    currency.quote.uSD.isChanged = true;
    currency.quote.uSD.updateIsIncrement(newIncrement: currency.quote.uSD.price.value < newPrice);
    currency.quote.uSD.updatePrice(newPrice: newPrice);
  }
}
