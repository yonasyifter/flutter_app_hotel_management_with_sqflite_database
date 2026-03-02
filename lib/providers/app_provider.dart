import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/day_entry.dart';
import '../services/db_service.dart';

class AppProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<DayEntry> _monthEntries = [];
  DayEntry? _currentEntry;
  DateTime _focusedMonth = DateTime.now();

  // Temporary per-session state for the day flow
  Map<int, int> _pendingPurchaseQty = {};
  Map<int, double> _pendingPurchasePrice = {};
  Map<int, double> _pendingSellPrice = {};
  Map<int, int> _pendingSalesQty = {};

  List<Product> get products => _products;
  List<Product> get activeProducts => _products.where((p) => p.active).toList();
  List<DayEntry> get monthEntries => _monthEntries;
  DayEntry? get currentEntry => _currentEntry;
  DateTime get focusedMonth => _focusedMonth;

  Map<int, int> get pendingPurchaseQty => _pendingPurchaseQty;
  Map<int, double> get pendingPurchasePrice => _pendingPurchasePrice;
  Map<int, double> get pendingSellPrice => _pendingSellPrice;
  Map<int, int> get pendingSalesQty => _pendingSalesQty;

  Future<void> loadProducts() async {
    _products = await DbService.getProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product p) async {
    final id = await DbService.insertProduct(p);
    _products.add(p.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateProduct(Product p) async {
    await DbService.updateProduct(p);
    final idx = _products.indexWhere((x) => x.id == p.id);
    if (idx >= 0) _products[idx] = p;
    notifyListeners();
  }

  Future<void> deactivateProduct(int id) async {
    await DbService.deactivateProduct(id);
    final idx = _products.indexWhere((x) => x.id == id);
    if (idx >= 0) _products[idx] = _products[idx].copyWith(active: false);
    notifyListeners();
  }

  Future<void> loadMonthEntries(DateTime month) async {
    _focusedMonth = month;
    _monthEntries = await DbService.getMonthEntries(month.year, month.month);
    notifyListeners();
  }

  DayEntry? getEntryForDay(int day) {
    try {
      return _monthEntries.firstWhere(
        (e) => e.date.day == day && e.date.month == _focusedMonth.month,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> openDay(DateTime date) async {
    await loadProducts();
    _currentEntry = await DbService.getOrCreateDayEntry(date, activeProducts);

    // Pre-fill pending state from existing entry
    _pendingPurchaseQty = {};
    _pendingPurchasePrice = {};
    _pendingSellPrice = {};
    _pendingSalesQty = {};

    for (final p in activeProducts) {
      _pendingPurchasePrice[p.id!] = p.buyPrice;
      _pendingSellPrice[p.id!] = p.sellPrice;
    }
    for (final pur in _currentEntry!.purchases) {
      _pendingPurchaseQty[pur.productId] = pur.qty;
      _pendingPurchasePrice[pur.productId] = pur.price;
    }
    for (final s in _currentEntry!.sales) {
      _pendingSalesQty[s.productId] = s.qtySold;
    }
    for (final p in activeProducts) {
      _pendingPurchaseQty[p.id!] ??= 0;
      _pendingSalesQty[p.id!] ??= 0;
    }

    notifyListeners();
  }

  void setPurchaseQty(int productId, int qty) {
    _pendingPurchaseQty[productId] = qty;
  }

  void setPurchasePrice(int productId, double price) {
    _pendingPurchasePrice[productId] = price;
  }

  void setSellPrice(int productId, double price) {
    _pendingSellPrice[productId] = price;
  }

  void setSalesQty(int productId, int qty) {
    _pendingSalesQty[productId] = qty;
  }

  Future<void> savePurchases() async {
    final items = activeProducts.map((p) => PurchaseItem(
          productId: p.id!,
          qty: _pendingPurchaseQty[p.id] ?? 0,
          price: _pendingPurchasePrice[p.id] ?? p.buyPrice,
        )).toList();

    await DbService.savePurchases(_currentEntry!.id!, items);

    // Update product buy prices
    for (final p in activeProducts) {
      final qty = _pendingPurchaseQty[p.id] ?? 0;
      if (qty > 0) {
        final newPrice = _pendingPurchasePrice[p.id] ?? p.buyPrice;
        if (newPrice != p.buyPrice) {
          await updateProduct(p.copyWith(buyPrice: newPrice));
        }
      }
    }

    _currentEntry = _currentEntry!.copyWith(purchases: items);
    notifyListeners();
  }

  Future<void> saveSellPrices() async {
    for (final p in activeProducts) {
      final newPrice = _pendingSellPrice[p.id] ?? p.sellPrice;
      if (newPrice != p.sellPrice) {
        await updateProduct(p.copyWith(sellPrice: newPrice));
      }
    }
    notifyListeners();
  }

  Future<void> saveSales() async {
    final items = activeProducts.map((p) => SaleItem(
          productId: p.id!,
          qtySold: _pendingSalesQty[p.id] ?? 0,
        )).toList();
    await DbService.saveSales(_currentEntry!.id!, items);
    _currentEntry = _currentEntry!.copyWith(sales: items);
    notifyListeners();
  }

  Future<void> completeDay() async {
    double revenue = 0, profit = 0;
    for (final p in activeProducts) {
      final sold = _pendingSalesQty[p.id] ?? 0;
      final sellPrice = _pendingSellPrice[p.id] ?? p.sellPrice;
      final buyPrice = _pendingPurchasePrice[p.id] ?? p.buyPrice;
      revenue += sold * sellPrice;
      profit += sold * (sellPrice - buyPrice);
    }
    await DbService.completeDayEntry(_currentEntry!.id!, revenue, profit);
    _currentEntry = _currentEntry!.copyWith(complete: true, totalRevenue: revenue, totalProfit: profit);
    await loadMonthEntries(_focusedMonth);
    notifyListeners();
  }

  // ── Summary helpers ──────────────────────────────────
  int getOpeningStock(int productId) => _currentEntry?.openingStock[productId] ?? 0;

  int getAvailableStock(int productId) {
    final opening = getOpeningStock(productId);
    final bought = _pendingPurchaseQty[productId] ?? 0;
    return opening + bought;
  }

  double get dailyRevenue {
    double total = 0;
    for (final p in activeProducts) {
      final sold = _pendingSalesQty[p.id] ?? 0;
      final price = _pendingSellPrice[p.id] ?? p.sellPrice;
      total += sold * price;
    }
    return total;
  }

  double get dailyProfit {
    double total = 0;
    for (final p in activeProducts) {
      final sold = _pendingSalesQty[p.id] ?? 0;
      final sellPrice = _pendingSellPrice[p.id] ?? p.sellPrice;
      final buyPrice = _pendingPurchasePrice[p.id] ?? p.buyPrice;
      total += sold * (sellPrice - buyPrice);
    }
    return total;
  }

  double get monthlyRevenue => _monthEntries.fold(0, (s, e) => s + e.totalRevenue);
  double get monthlyProfit => _monthEntries.fold(0, (s, e) => s + e.totalProfit);
  int get completedDaysCount => _monthEntries.where((e) => e.complete).length;

  String? get bestDay {
    if (_monthEntries.isEmpty) return null;
    final best = _monthEntries.reduce((a, b) => a.totalRevenue > b.totalRevenue ? a : b);
    return best.totalRevenue > 0 ? 'Day ${best.date.day}' : null;
  }
}
