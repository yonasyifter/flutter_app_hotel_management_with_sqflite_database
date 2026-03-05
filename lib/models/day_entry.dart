import 'household_expense.dart';

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
  final double totalExpenses;
  final double netProfit;
  final Map<int, int> openingStock;
  final List<PurchaseItem> purchases;
  final List<SaleItem> sales;
  final List<HouseholdExpense> expenses;

  DayEntry({
    this.id,
    required this.date,
    this.complete = false,
    this.totalRevenue = 0,
    this.totalProfit = 0,
    this.totalExpenses = 0,
    this.netProfit = 0,
    this.openingStock = const {},
    this.purchases = const [],
    this.sales = const [],
    this.expenses = const [],
  });

  DayEntry copyWith({
    int? id,
    DateTime? date,
    bool? complete,
    double? totalRevenue,
    double? totalProfit,
    double? totalExpenses,
    double? netProfit,
    Map<int, int>? openingStock,
    List<PurchaseItem>? purchases,
    List<SaleItem>? sales,
    List<HouseholdExpense>? expenses,
  }) {
    return DayEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      complete: complete ?? this.complete,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalProfit: totalProfit ?? this.totalProfit,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      netProfit: netProfit ?? this.netProfit,
      openingStock: openingStock ?? this.openingStock,
      purchases: purchases ?? this.purchases,
      sales: sales ?? this.sales,
      expenses: expenses ?? this.expenses,
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
        'total_expenses': totalExpenses,
        'net_profit': netProfit,
      };

  factory DayEntry.fromMap(Map<String, dynamic> map) => DayEntry(
        id: map['id'],
        date: DateTime.parse(map['date']),
        complete: map['complete'] == 1,
        totalRevenue: map['total_revenue'] ?? 0.0,
        totalProfit: map['total_profit'] ?? 0.0,
        totalExpenses: map['total_expenses'] ?? 0.0,
        netProfit: map['net_profit'] ?? 0.0,
      );
}
