class Product {
  final int? id;
  final String name;
  final double buyPrice;
  final double sellPrice;
  final int openingStock;
  final bool active;

  Product({
    this.id,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    this.openingStock = 0,
    this.active = true,
  });

  Product copyWith({
    int? id,
    String? name,
    double? buyPrice,
    double? sellPrice,
    int? openingStock,
    bool? active,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      openingStock: openingStock ?? this.openingStock,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'buy_price': buyPrice,
        'sell_price': sellPrice,
        'opening_stock': openingStock,
        'active': active ? 1 : 0,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        name: map['name'],
        buyPrice: map['buy_price'],
        sellPrice: map['sell_price'],
        openingStock: map['opening_stock'] ?? 0,
        active: map['active'] == 1,
      );
}
