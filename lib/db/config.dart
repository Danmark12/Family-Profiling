// lib/db/config.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  // ---------------- DATABASE INIT ----------------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('family.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // ---------------- ONCREATE ----------------
  Future _createDB(Database db, int version) async {
    // ---------------- HOUSEHOLDS TABLE ----------------
    await db.execute('''
CREATE TABLE households(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  householdNo INTEGER,
  zone TEXT,
  barangay TEXT,
  fourPs INTEGER DEFAULT 0,
  indigenousPeople INTEGER DEFAULT 0,
  iodizedSalt INTEGER DEFAULT 0,
  fatherName TEXT,
  fatherOccupation TEXT,
  fatherEducation TEXT,
  motherName TEXT,
  motherOccupation TEXT,
  motherEducation TEXT,
  male INTEGER DEFAULT 0,
  female INTEGER DEFAULT 0,
  total INTEGER DEFAULT 0,
  families INTEGER DEFAULT 0,
  fullyImmunized INTEGER DEFAULT 0,
  exclusive INTEGER DEFAULT 0,
  mixed INTEGER DEFAULT 0,
  bottleFed INTEGER DEFAULT 0,
  complementary INTEGER DEFAULT 0,
  preg19 INTEGER DEFAULT 0,
  preg20 INTEGER DEFAULT 0,
  lactating INTEGER DEFAULT 0,
  infant0to5 INTEGER DEFAULT 0,
  infant6to11 INTEGER DEFAULT 0,
  child12to23 INTEGER DEFAULT 0,
  child24to59 INTEGER DEFAULT 0,
  age5to9 INTEGER DEFAULT 0,
  age10to19 INTEGER DEFAULT 0,
  age20to59 INTEGER DEFAULT 0,
  age60above INTEGER DEFAULT 0,
  pwd INTEGER DEFAULT 0,
  severelyUnderweight INTEGER DEFAULT 0,
  underweight INTEGER DEFAULT 0,
  normal INTEGER DEFAULT 0,
  severelyWasted INTEGER DEFAULT 0,
  wasted INTEGER DEFAULT 0,
  overweight INTEGER DEFAULT 0,
  obese INTEGER DEFAULT 0,
  severelyStunted INTEGER DEFAULT 0,
  stunted INTEGER DEFAULT 0,
  toilet TEXT,
  garbage TEXT,
  water TEXT,
  food TEXT,
  dwellingType TEXT,
  archived INTEGER DEFAULT 0
)
''');

    // ---------------- USERS TABLE ----------------
    await db.execute('''
CREATE TABLE users(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE,
  barangay TEXT,
  password TEXT
)
''');
  }

  // ---------------- ONUPGRADE ----------------
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // future upgrades here
      // e.g., await db.execute("ALTER TABLE users ADD COLUMN email TEXT;");
    }
  }

  // ---------------- USERS FUNCTIONS ----------------

  // Register a new user
  Future<int> registerUser(String name, String barangay, String password) async {
    final db = await database;
    return await db.insert('users', {
      'name': name,
      'barangay': barangay,
      'password': password
    });
  }

  // Login user (checks name + password)
  Future<Map<String, dynamic>?> loginUser(String name, String password) async {
    final db = await database;

    final res = await db.query(
      'users',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (res.isNotEmpty) {
      if (res.first['password'] == password) {
        return res.first;
      }
    }
    return null;
  }

  // Get user by ID (for profile page)
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // Alias for loginUserById (so profile.dart works)
Future<Map<String, dynamic>?> loginUserById(int id) async {
  return getUserById(id);
}
// ---------------- UPDATE USER ----------------
Future<int> updateUser(int id, Map<String, dynamic> data) async {
  final db = await database;
  return await db.update(
    'users',
    data,
    where: 'id = ?',
    whereArgs: [id],
  );
}
  // ---------------- HOUSEHOLD FUNCTIONS ----------------

  Future<int?> getLastHouseholdNo() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT householdNo FROM households ORDER BY householdNo DESC LIMIT 1",
    );
    if (result.isNotEmpty && result.first['householdNo'] != null) {
      return result.first['householdNo'] as int;
    }
    return null;
  }

  Future<int> insertHousehold(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('households', data);
  }

  Future<List<Map<String, dynamic>>> getAllHouseholds({bool includeArchived = false}) async {
    final db = await database;
    final whereClause = includeArchived ? null : 'archived = 0';
    return await db.query(
      'households',
      where: whereClause,
      orderBy: 'householdNo DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getHouseholdsByBarangay(String barangay, {bool includeArchived = false}) async {
    final db = await database;
    final whereClause = includeArchived ? 'barangay = ?' : 'barangay = ? AND archived = 0';
    return await db.query(
      'households',
      where: whereClause,
      whereArgs: [barangay],
      orderBy: 'householdNo DESC',
    );
  }

  Future<Map<String, dynamic>?> getHousehold(int id) async {
    final db = await database;
    final result = await db.query(
      'households',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<void> updateHousehold(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update(
      'households',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> archiveHousehold(int id) async {
    final db = await database;
    await db.update(
      'households',
      {'archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> unarchiveHousehold(int id) async {
    final db = await database;
    await db.update(
      'households',
      {'archived': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteHouseholdPermanently(int id) async {
    final db = await database;
    await db.delete(
      'households',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getArchivedHouseholds() async {
    final db = await database;
    return await db.query(
      'households',
      where: 'archived = 1',
      orderBy: 'householdNo DESC',
    );
  }
}