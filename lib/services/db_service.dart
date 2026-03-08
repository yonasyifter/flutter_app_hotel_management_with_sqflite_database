import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/day_entry.dart';
import '../models/household_expense.dart';

class DbService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'stockbook.db'),
      version: 3,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE day_entries ADD COLUMN total_expenses REAL DEFAULT 0');
          await db.execute('ALTER TABLE day_entries ADD COLUMN net_profit REAL DEFAULT 0');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS household_expenses (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              day_entry_id INTEGER NOT NULL,
              description TEXT NOT NULL,
              amount REAL NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              email TEXT UNIQUE NOT NULL,
              password TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        buy_price REAL NOT NULL,
        sell_price REAL NOT NULL,
        opening_stock INTEGER DEFAULT 0,
        active INTEGER DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE day_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        complete INTEGER DEFAULT 0,
        total_revenue REAL DEFAULT 0,
        total_profit REAL DEFAULT 0,
        total_expenses REAL DEFAULT 0,
        net_profit REAL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE opening_stock (
        day_entry_id INTEGER,
        product_id INTEGER,
        qty INTEGER DEFAULT 0,
        PRIMARY KEY (day_entry_id, product_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_entry_id INTEGER,
        product_id INTEGER,
        qty INTEGER DEFAULT 0,
        price REAL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_entry_id INTEGER,
        product_id INTEGER,
        qty_sold INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE household_expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_entry_id INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');
  }

  // ─── USERS ──────────────────────────────────────
  static Future<int> registerUser(String email, String password) async {
    final database = await db;
    final count = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM users')) ?? 0;
    if (count >= 2) return -1;
    return database.insert('users', {'email': email, 'password': password});
  }

  static Future<bool> loginUser(String email, String password) async {
    final database = await db;
    final rows = await database.query('users',
        where: 'email = ? AND password = ?', whereArgs: [email, password]);
    return rows.isNotEmpty;
  }

  static Future<int> getUserCount() async {
    final database = await db;
    return Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM users')) ?? 0;
  }

  // ─── PRODUCTS ───────────────────────────────────
  static Future<List<Product>> getProducts({bool activeOnly = false}) async {
    final database = await db;
    final where = activeOnly ? 'WHERE active = 1' : '';
    final rows = await database.rawQuery('SELECT * FROM products $where ORDER BY name');
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  static Future<int> insertProduct(Product p) async {
    final database = await db;
    return database.insert('products', p.toMap()..remove('id'));
  }

  static Future<void> updateProduct(Product p) async {
    final database = await db;
    await database.update('products', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  static Future<void> deactivateProduct(int id) async {
    final database = await db;
    await database.update('products', {'active': 0}, where: 'id = ?', whereArgs: [id]);
  }

  // ─── DAY ENTRIES ─────────────────────────────────

  static Future<DayEntry?> getDayEntry(DateTime date) async {
    final database = await db;
    final rows = await database.query('day_entries', where: 'date = ?', whereArgs: [_dateStr(date)]);
    if (rows.isEmpty) return null;
    return _hydrateDayEntry(database, rows.first);
  }

  static Future<DayEntry?> getDayEntryById(int id) async {
    final database = await db;
    final rows = await database.query('day_entries', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _hydrateDayEntry(database, rows.first);
  }

  static Future<DayEntry> _hydrateDayEntry(
      Database database, Map<String, dynamic> row) async {
    final entry = DayEntry.fromMap(row);
    final id = entry.id!;

    final osRows = await database.query('opening_stock', where: 'day_entry_id = ?', whereArgs: [id]);
    final openingStockMap = {for (var r in osRows) r['product_id'] as int: r['qty'] as int};

    final purchaseRows = await database.query('purchases', where: 'day_entry_id = ?', whereArgs: [id]);
    final purchases = purchaseRows.map((r) => PurchaseItem.fromMap(r)).toList();

    final saleRows = await database.query('sales', where: 'day_entry_id = ?', whereArgs: [id]);
    final sales = saleRows.map((r) => SaleItem.fromMap(r)).toList();

    final expenseRows = await database.query('household_expenses',
        where: 'day_entry_id = ?', whereArgs: [id]);
    final expenses = expenseRows.map((r) => HouseholdExpense.fromMap(r)).toList();

    return entry.copyWith(
        openingStock: openingStockMap, purchases: purchases, sales: sales, expenses: expenses);
  }

  static Future<DayEntry> getOrCreateDayEntry(DateTime date, List<Product> products) async {
    final existing = await getDayEntry(date);
    if (existing != null) return existing;

    final openingStockMap = <int, int>{};
    for (final p in products) {
      openingStockMap[p.id!] = await _computeClosingStockBefore(p.id!, date) ?? p.openingStock;
    }

    final database = await db;
    final id = await database.insert('day_entries', {
      'date': _dateStr(date),
      'complete': 0,
      'total_revenue': 0,
      'total_profit': 0,
      'total_expenses': 0,
      'net_profit': 0,
    });

    for (final entry in openingStockMap.entries) {
      await database.insert('opening_stock', {
        'day_entry_id': id,
        'product_id': entry.key,
        'qty': entry.value,
      });
    }

    return DayEntry(id: id, date: date, openingStock: openingStockMap);
  }

  static Future<int?> _computeClosingStockBefore(int productId, DateTime date) async {
    final database = await db;
    final rows = await database.rawQuery('''
      SELECT 
        COALESCE(os.qty, 0) as opening,
        COALESCE(p.qty, 0) as purchased,
        COALESCE(s.qty_sold, 0) as sold
      FROM day_entries de
      LEFT JOIN opening_stock os ON os.day_entry_id = de.id AND os.product_id = ?
      LEFT JOIN purchases p ON p.day_entry_id = de.id AND p.product_id = ?
      LEFT JOIN sales s ON s.day_entry_id = de.id AND s.product_id = ?
      WHERE de.date < ? AND de.complete = 1
      ORDER BY de.date DESC
      LIMIT 1
    ''', [productId, productId, productId, _dateStr(date)]);

    if (rows.isEmpty) return null;
    final row = rows.first;
    final opening = (row['opening'] as int?) ?? 0;
    final purchased = (row['purchased'] as int?) ?? 0;
    final sold = (row['sold'] as int?) ?? 0;
    return (opening + purchased - sold).clamp(0, 99999);
  }

  /// Compute closing stock for a product from a specific completed day entry.
  static Future<int> computeClosingStockForDay(int dayEntryId, int productId) async {
    final database = await db;

    final osRows = await database.query('opening_stock',
        where: 'day_entry_id = ? AND product_id = ?', whereArgs: [dayEntryId, productId]);
    final opening = osRows.isNotEmpty ? (osRows.first['qty'] as int? ?? 0) : 0;

    final purRows = await database.query('purchases',
        where: 'day_entry_id = ? AND product_id = ?', whereArgs: [dayEntryId, productId]);
    final purchased = purRows.isNotEmpty ? (purRows.first['qty'] as int? ?? 0) : 0;

    final saleRows = await database.query('sales',
        where: 'day_entry_id = ? AND product_id = ?', whereArgs: [dayEntryId, productId]);
    final sold = saleRows.isNotEmpty ? (saleRows.first['qty_sold'] as int? ?? 0) : 0;

    return (opening + purchased - sold).clamp(0, 99999);
  }

  /// Get the current closing stock for a product (based on most recent completed day).
  /// Returns the product's base openingStock if no completed days exist (returns -1 sentinel).
  static Future<int> getCurrentClosingStock(int productId) async {
    final database = await db;
    final rows = await database.rawQuery('''
      SELECT 
        de.id as entry_id,
        COALESCE(os.qty, 0) as opening,
        COALESCE(p.qty, 0) as purchased,
        COALESCE(s.qty_sold, 0) as sold
      FROM day_entries de
      LEFT JOIN opening_stock os ON os.day_entry_id = de.id AND os.product_id = ?
      LEFT JOIN purchases p ON p.day_entry_id = de.id AND p.product_id = ?
      LEFT JOIN sales s ON s.day_entry_id = de.id AND s.product_id = ?
      WHERE de.complete = 1
      ORDER BY de.date DESC
      LIMIT 1
    ''', [productId, productId, productId]);

    if (rows.isEmpty) return -1; // sentinel: no history yet
    final row = rows.first;
    final opening = (row['opening'] as int?) ?? 0;
    final purchased = (row['purchased'] as int?) ?? 0;
    final sold = (row['sold'] as int?) ?? 0;
    return (opening + purchased - sold).clamp(0, 99999);
  }

  /// After a day is completed/re-completed, cascade opening stock updates
  /// forward to all subsequent day entries in the database.
  static Future<void> cascadeOpeningStockForward(int fromDayEntryId, String fromDate) async {
    final database = await db;

    // All day entries strictly after the edited day, oldest first
    final laterRows = await database.query(
      'day_entries',
      where: 'date > ?',
      whereArgs: [fromDate],
      orderBy: 'date ASC',
    );
    if (laterRows.isEmpty) return;

    // Collect all product IDs that appear in the edited day
    final productIdSet = <int>{};
    final osRows = await database.rawQuery(
        'SELECT DISTINCT product_id FROM opening_stock WHERE day_entry_id = ?', [fromDayEntryId]);
    for (final r in osRows) productIdSet.add(r['product_id'] as int);
    final purRows = await database.rawQuery(
        'SELECT DISTINCT product_id FROM purchases WHERE day_entry_id = ?', [fromDayEntryId]);
    for (final r in purRows) productIdSet.add(r['product_id'] as int);
    final salesRows = await database.rawQuery(
        'SELECT DISTINCT product_id FROM sales WHERE day_entry_id = ?', [fromDayEntryId]);
    for (final r in salesRows) productIdSet.add(r['product_id'] as int);

    int prevDayEntryId = fromDayEntryId;

    for (final row in laterRows) {
      final thisDayEntryId = row['id'] as int;

      for (final productId in productIdSet) {
        final newOpening = await computeClosingStockForDay(prevDayEntryId, productId);

        final existing = await database.query('opening_stock',
            where: 'day_entry_id = ? AND product_id = ?',
            whereArgs: [thisDayEntryId, productId]);
        if (existing.isEmpty) {
          await database.insert('opening_stock', {
            'day_entry_id': thisDayEntryId,
            'product_id': productId,
            'qty': newOpening,
          });
        } else {
          await database.update(
            'opening_stock',
            {'qty': newOpening},
            where: 'day_entry_id = ? AND product_id = ?',
            whereArgs: [thisDayEntryId, productId],
          );
        }
      }

      prevDayEntryId = thisDayEntryId;
    }
  }

  static Future<void> savePurchases(int dayEntryId, List<PurchaseItem> items) async {
    final database = await db;
    await database.delete('purchases', where: 'day_entry_id = ?', whereArgs: [dayEntryId]);
    for (final item in items) {
      await database.insert('purchases', item.toMap(dayEntryId));
    }
  }

  static Future<void> saveSales(int dayEntryId, List<SaleItem> items) async {
    final database = await db;
    await database.delete('sales', where: 'day_entry_id = ?', whereArgs: [dayEntryId]);
    for (final item in items) {
      await database.insert('sales', item.toMap(dayEntryId));
    }
  }

  static Future<void> replaceExpenses(int dayEntryId, List<HouseholdExpense> items) async {
    final database = await db;
    await database.delete('household_expenses',
        where: 'day_entry_id = ?', whereArgs: [dayEntryId]);
    for (final item in items) {
      await database.insert('household_expenses', {
        'day_entry_id': dayEntryId,
        'description': item.description,
        'amount': item.amount,
      });
    }
  }

  static Future<void> completeDayEntry(
      int id, double revenue, double profit, double expenses, double netProfit) async {
    final database = await db;
    await database.update('day_entries', {
      'complete': 1,
      'total_revenue': revenue,
      'total_profit': profit,
      'total_expenses': expenses,
      'net_profit': netProfit,
    }, where: 'id = ?', whereArgs: [id]);
  }

  /// Light-weight month summary (no sub-tables) — used for calendar + monthly totals.
  static Future<List<DayEntry>> getMonthEntries(int year, int month) async {
    final database = await db;
    final from = '$year-${month.toString().padLeft(2, '0')}-01';
    final to = '$year-${month.toString().padLeft(2, '0')}-31';
    final rows = await database.query('day_entries',
        where: 'date >= ? AND date <= ?', whereArgs: [from, to]);
    return rows.map((r) => DayEntry.fromMap(r)).toList();
  }

  /// Full month entries with sub-tables — used for the home screen daily summary table.
  static Future<List<DayEntry>> getFullMonthEntries(int year, int month) async {
    final database = await db;
    final from = '$year-${month.toString().padLeft(2, '0')}-01';
    final to = '$year-${month.toString().padLeft(2, '0')}-31';
    final rows = await database.query('day_entries',
        where: 'date >= ? AND date <= ?', whereArgs: [from, to]);
    final entries = <DayEntry>[];
    for (final row in rows) {
      entries.add(await _hydrateDayEntry(database, row));
    }
    return entries;
  }

  static String _dateStr(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
