import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(
      await getDatabasesPath(),
      'pos_system_final_v2.db', // Naya naam taake purana conflict khatam ho jaye
    );
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Products Table
    // ✅ Fix: 'is_synced' ko 'isSynced' kar diya taake SyncService se match kare
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT,
        sku TEXT,
        category TEXT,
        price REAL,
        cost_price REAL,
        stock_quantity INTEGER,
        image_path TEXT,
        isSynced INTEGER DEFAULT 0 
      )
    ''');

    // 2. Sales Table
    // ✅ Fix: 'items' column wapis dala hai kyunke SyncService ko JSON chahiye
    await db.execute('''
      CREATE TABLE sales(
        id TEXT PRIMARY KEY,
        invoice_number TEXT,
        customer_id TEXT,
        total_amount REAL,
        timestamp TEXT,
        items TEXT, 
        isSynced INTEGER DEFAULT 0
      )
    ''');

    // 3. Sale Items Table (Relational Data ke liye - Optional but good to keep)
    await db.execute('''
      CREATE TABLE sale_items(
        id TEXT PRIMARY KEY,
        sale_id TEXT,
        product_id TEXT,
        quantity INTEGER,
        unit_price REAL,
        subtotal REAL
      )
    ''');

    // 4. Customers Table
    // ✅ Note: Yahan 'is_synced' hi rakha hai kyunke SyncService me yehi use hua tha
    await db.execute('''
      CREATE TABLE customers(
        id TEXT PRIMARY KEY,
        name TEXT,
        phone TEXT,
        address TEXT,
        current_balance REAL DEFAULT 0.0,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // 5. Expenses Table
    // ✅ Fix: 'isSynced' use kiya
    await db.execute('''
      CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        title TEXT,
        amount REAL,
        category TEXT,
        date TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    // 6. Cart Table (Temporary storage ke liye)
    await db.execute('''
      CREATE TABLE cart(
        id TEXT PRIMARY KEY,
        productId TEXT,
        name TEXT,
        price REAL,
        quantity INTEGER
      )
    ''');

    print("✅ Database Created Successfully with Correct Columns for Sync!");
  }
}
