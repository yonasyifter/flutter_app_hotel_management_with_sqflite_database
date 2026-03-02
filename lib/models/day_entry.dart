class PurchaseItem {
  final int productId;
  final int qty;
  final double price;

  PurchaseItem({required this.productId, required this.qty, required this.price});

  Map<String, dynamic> toMap(int dayEntryId) => {
        'day_entry_id': dayEntryId,
        'product_id': productId,
        'qty': qty,
        'price': price,
      };

  factory PurchaseItem.fromMap(Map<String, dynamic> map) => PurchaseItem(
        productId: map['product_id'],
        qty: map['qty'],
        price: map['price'],
      );
}

class SaleItem {
  final int productId;
  final int qtySold;

  SaleItem({required this.productId, required this.qtySold});

  Map<String, dynamic> toMap(int dayEntryId) => {
        'day_entry_id': dayEntryId,
        'product_id': productId,
        'qty_sold': qtySold,
      };

  factory SaleItem.fromMap(Map<String, dynamic> map) => SaleItem(
        productId: map['product_id'],
        qtySold: map['qty_sold'],
      );
}

class DayEntry {
  final int? id;
  final DateTime date;
  final bool complete;
  final double totalRevenue;
  final double totalProfit;
  final Map<int, int> openingStock;    // productId -> qty
  final List<PurchaseItem> purchases;
  final List<SaleItem> sales;

  DayEntry({
    this.id,
    required this.date,
    this.complete = false,
    this.totalRevenue = 0,
    this.totalProfit = 0,
    this.openingStock = const {},
    this.purchases = const [],
    this.sales = const [],
  });

  DayEntry copyWith({
    int? id,
    DateTime? date,
    bool? complete,
    double? totalRevenue,
    double? totalProfit,
    Map<int, int>? openingStock,
    List<PurchaseItem>? purchases,
    List<SaleItem>? sales,
  }) {
    return DayEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      complete: complete ?? this.complete,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalProfit: totalProfit ?? this.totalProfit,
      openingStock: openingStock ?? this.openingStock,
      purchases: purchases ?? this.purchases,
      sales: sales ?? this.sales,
    );
  }

  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': dateKey,
        'complete': complete ? 1 : 0,
        'total_revenue': totalRevenue,
        'total_profit': totalProfit,
      };

  factory DayEntry.fromMap(Map<String, dynamic> map) => DayEntry(
        id: map['id'],
        date: DateTime.parse(map['date']),
        complete: map['complete'] == 1,
        totalRevenue: map['total_revenue'] ?? 0.0,
        totalProfit: map['total_profit'] ?? 0.0,
      );
}
