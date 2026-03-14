import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DataClassName('Expense')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get merchantName => text().withLength(min: 1, max: 255)();
  TextColumn get category => text().withLength(min: 1, max: 100)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get receiptImagePath => text().nullable()();
  TextColumn get receiptText => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExpenseCategory')
class ExpenseCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get color => integer().withDefault(const Constant(0xFF2196F3))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Expenses, ExpenseCategories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _insertDefaultCategories();
        await seedSampleExpenses();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle database upgrades
      },
    );
  }

  Future<void> _insertDefaultCategories() async {
    final defaultCategories = [
      {'id': 'food', 'name': 'อาหาร', 'description': 'ค่าอาหารและเครื่องดื่ม', 'icon': 'restaurant', 'color': 0xFFFF5722},
      {'id': 'transport', 'name': 'การเดินทาง', 'description': 'ค่าเดินทางและยานพาหนะ', 'icon': 'directions_car', 'color': 0xFF2196F3},
      {'id': 'shopping', 'name': 'ช้อปปิ้ง', 'description': 'การซื้อสินค้าและบริการ', 'icon': 'shopping_cart', 'color': 0xFF9C27B0},
      {'id': 'entertainment', 'name': 'บันเทิง', 'description': 'ค่าบันเทิงและนันทนาการ', 'icon': 'movie', 'color': 0xFFE91E63},
      {'id': 'health', 'name': 'สุขภาพ', 'description': 'ค่ารักษาพยาบาลและสุขภาพ', 'icon': 'local_hospital', 'color': 0xFF4CAF50},
      {'id': 'education', 'name': 'การศึกษา', 'description': 'ค่าการศึกษาและอบรม', 'icon': 'school', 'color': 0xFF009688},
      {'id': 'utilities', 'name': 'สาธารณูปโภค', 'description': 'ค่าไฟฟ้า น้ำ โทรศัพท์', 'icon': 'power', 'color': 0xFFFF9800},
      {'id': 'other', 'name': 'อื่นๆ', 'description': 'ค่าใช้จ่ายอื่นๆ', 'icon': 'more_horiz', 'color': 0xFF607D8B},
    ];

    for (final category in defaultCategories) {
      await into(expenseCategories).insert(ExpenseCategoriesCompanion.insert(
        id: category['id'] as String,
        name: category['name'] as String,
        description: Value(category['description'] as String?),
        icon: Value(category['icon'] as String?),
        color: Value(category['color'] as int),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  }

  // ── Sample data ────────────────────────────────────────────────
  Future<void> seedSampleExpenses() async {
    final now = DateTime.now();
    final d = (int days) => now.subtract(Duration(days: days));

    final entries = [
      // ── Food & Drink (11) ─────────────────────────
      _seed('seed-001', "McDonald's", 'food', 185.00, d(1), "Big Mac Set"),
      _seed('seed-002', 'Starbucks', 'food', 175.00, d(2), "Caramel Macchiato"),
      _seed('seed-003', 'KFC', 'food', 249.00, d(3), "Zinger Combo"),
      _seed('seed-004', 'MK Restaurant', 'food', 650.00, d(5), "Shabu set for 2"),
      _seed('seed-005', 'Grab Food', 'food', 320.00, d(6), "Delivery order"),
      _seed('seed-006', 'The Pizza Company', 'food', 499.00, d(8), "Large pizza"),
      _seed('seed-007', '7-Eleven', 'food', 85.00, d(9), "Snacks & drinks"),
      _seed('seed-008', 'Shabu Shi', 'food', 399.00, d(11), "Unlimited set"),
      _seed('seed-009', 'Bar B Q Plaza', 'food', 580.00, d(13), "BBQ dinner"),
      _seed('seed-010', "Swensen's", 'food', 299.00, d(15), "Ice cream + waffle"),
      _seed('seed-011', 'Café Amazon', 'food', 95.00, d(17), "Iced coffee"),
      // ── Transport (7) ─────────────────────────────
      _seed('seed-012', 'Grab Car', 'transport', 145.00, d(1), "Office to home"),
      _seed('seed-013', 'BTS Skytrain', 'transport', 94.00, d(3), "Monthly top-up"),
      _seed('seed-014', 'PTT Gas Station', 'transport', 1200.00, d(7), "Full tank"),
      _seed('seed-015', 'MRT', 'transport', 56.00, d(10), "Trip fare"),
      _seed('seed-016', 'Bolt Taxi', 'transport', 89.00, d(12), "Airport transfer"),
      _seed('seed-017', 'Shell Gas Station', 'transport', 980.00, d(32), "Full tank"),
      _seed('seed-018', 'Airport Rail Link', 'transport', 45.00, d(40), "Suvarnabhumi"),
      // ── Shopping (6) ──────────────────────────────
      _seed('seed-019', 'Lazada', 'shopping', 899.00, d(2), "Phone case & cable"),
      _seed('seed-020', 'Shopee', 'shopping', 350.00, d(4), "Household items"),
      _seed('seed-021', 'Big C', 'shopping', 1250.00, d(8), "Weekly groceries"),
      _seed('seed-022', 'Central Department Store', 'shopping', 2800.00, d(14), "Clothing"),
      _seed('seed-023', 'Tops Supermarket', 'shopping', 745.00, d(18), "Groceries"),
      _seed('seed-024', 'IKEA', 'shopping', 3500.00, d(35), "Desk & chair"),
      // ── Entertainment (5) ─────────────────────────
      _seed('seed-025', 'Netflix', 'entertainment', 299.00, d(1), "Monthly subscription"),
      _seed('seed-026', 'SF Cinema', 'entertainment', 320.00, d(6), "Movie x2 tickets"),
      _seed('seed-027', 'Spotify', 'entertainment', 59.00, d(7), "Premium monthly"),
      _seed('seed-028', 'Major Cineplex', 'entertainment', 480.00, d(22), "Premiere ticket"),
      _seed('seed-029', 'PlayStation Store', 'entertainment', 890.00, d(38), "Game purchase"),
      // ── Health (5) ────────────────────────────────
      _seed('seed-030', 'Watsons', 'health', 455.00, d(3), "Vitamins & skincare"),
      _seed('seed-031', 'Boots Pharmacy', 'health', 320.00, d(9), "Medicine"),
      _seed('seed-032', 'Fitness First', 'health', 1490.00, d(15), "Monthly membership"),
      _seed('seed-033', 'Samitivej Hospital', 'health', 2800.00, d(33), "Annual check-up"),
      _seed('seed-034', 'Dental Clinic', 'health', 1500.00, d(45), "Scaling & polish"),
      // ── Education (4) ─────────────────────────────
      _seed('seed-035', 'Udemy', 'education', 399.00, d(5), "Flutter course"),
      _seed('seed-036', "Se-Ed Bookstore", 'education', 650.00, d(11), "Tech books x3"),
      _seed('seed-037', 'Coursera', 'education', 890.00, d(29), "Data Science cert"),
      _seed('seed-038', 'AUA Language School', 'education', 4500.00, d(50), "English class"),
      // ── Utilities (3) ─────────────────────────────
      _seed('seed-039', 'AIS Mobile', 'utilities', 599.00, d(4), "Monthly plan"),
      _seed('seed-040', 'True Internet', 'utilities', 790.00, d(20), "Fiber 1Gbps"),
    ];

    for (final entry in entries) {
      await into(expenses).insertOnConflictUpdate(entry);
    }
  }

  ExpensesCompanion _seed(
    String id,
    String merchant,
    String category,
    double amount,
    DateTime date,
    String notes,
  ) {
    return ExpensesCompanion.insert(
      id: id,
      merchantName: merchant,
      category: category,
      amount: amount,
      date: date,
      notes: Value(notes),
      createdAt: date,
      updatedAt: date,
    );
  }

  Future<void> deleteSampleExpenses() async {
    await (delete(expenses)
          ..where((t) => t.id.isIn(List.generate(40, (i) => 'seed-${(i + 1).toString().padLeft(3, '0')}'))))
        .go();
  }

  // Expense queries
  Future<List<Expense>> getAllExpenses() {
    return (select(expenses)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();
  }
  
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) {
    return (select(expenses)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<Expense>> getExpensesByCategory(String categoryId) {
    return (select(expenses)
          ..where((t) => t.category.equals(categoryId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<Expense?> getExpenseById(String id) {
    return (select(expenses)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertExpense(ExpensesCompanion entry) {
    return into(expenses).insert(entry);
  }

  Future<void> updateExpense(ExpensesCompanion entry) {
    return update(expenses).replace(entry);
  }

  Future<void> deleteExpense(String id) {
    return (delete(expenses)..where((t) => t.id.equals(id))).go();
  }

  // Category queries
  Future<List<ExpenseCategory>> getAllCategories() => select(expenseCategories).get();
  
  Future<ExpenseCategory?> getCategoryById(String id) {
    return (select(expenseCategories)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<double> getTotalExpensesByDateRange(DateTime start, DateTime end) async {
    final query = selectOnly(expenses)
      ..addColumns([expenses.amount.sum()])
      ..where(expenses.date.isBetweenValues(start, end));
    
    final result = await query.getSingle();
    return result.read(expenses.amount.sum()) ?? 0.0;
  }

  Future<Map<String, double>> getExpensesByCategorySum(DateTime start, DateTime end) async {
    final query = selectOnly(expenses)
      ..addColumns([expenses.category, expenses.amount.sum()])
      ..where(expenses.date.isBetweenValues(start, end))
      ..groupBy([expenses.category]);
    
    final results = await query.get();
    final Map<String, double> categorySums = {};
    
    for (final result in results) {
      final category = result.read(expenses.category);
      if (category != null) {
        final amount = result.read(expenses.amount.sum()) ?? 0.0;
        categorySums[category] = amount;
      }
    }
    
    return categorySums;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'expenses_db.sqlite'));
    return NativeDatabase(file);
  });
}
