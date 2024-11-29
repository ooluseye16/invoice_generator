class Goods {
  final String description;
  final int quantity;
  final double price;

  Goods({
    required this.description,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'price': price,
    };
  }
}
