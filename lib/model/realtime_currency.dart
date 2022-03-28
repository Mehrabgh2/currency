class RealtimeCurrency {
  String productId;
  String price;

  RealtimeCurrency(
      {required this.productId,
      required this.price});

  factory RealtimeCurrency.fromJson(Map<String, dynamic> json) {
    final productId = json['product_id'];
    final price = json['price'];
    return RealtimeCurrency(
        productId: productId, price: price);
  }
}
