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
      version: 1,
      onCreate: _createDB,
    );
  }

  // ---------------- ONCREATE ----------------
  Future _createDB(Database db, int version) async {
    // ---------------- USERS TABLE ----------------
    await db.execute('''
CREATE TABLE users(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE,
  barangay TEXT,
  password TEXT
)
''');

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
  shared INTEGER DEFAULT 0,
  garbage TEXT,
  water TEXT,
  food TEXT,
  dwellingType TEXT,
  archived INTEGER DEFAULT 0,
  userId INTEGER,
  created_at TEXT,
  updated_at TEXT
)
''');
  }

  // ---------------- USERS FUNCTIONS ----------------
  Future<int> registerUser(String name, String barangay, String password) async {
    final db = await database;
    return await db.insert('users', {
      'name': name,
      'barangay': barangay,
      'password': password
    });
  }

  Future<Map<String, dynamic>?> loginUser(String name, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (res.isNotEmpty && res.first['password'] == password) {
      return res.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<Map<String, dynamic>?> loginUserById(int id) async {
    return getUserById(id);
  }

  Future<int> updateUser(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  // ✅ DELETE USER METHOD - ADD THIS
  Future<void> deleteUser(int userId) async {
    final db = await database;
    // First delete all households linked to this user
    await db.delete('households', where: 'userId = ?', whereArgs: [userId]);
    // Then delete the user
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  // ✅ VERIFY PASSWORD METHOD - ADD THIS (OPTIONAL)
  Future<bool> verifyUserPassword(int userId, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, password],
    );
    return res.isNotEmpty;
  }

  // ---------------- HOUSEHOLDS FUNCTIONS ----------------
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

  // ----------- NEW METHOD FOR USER-SPECIFIC HOUSEHOLD NO -----------
  Future<int?> getLastHouseholdNoByUser(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT householdNo FROM households WHERE userId = ? ORDER BY householdNo DESC LIMIT 1",
      [userId],
    );
    if (result.isNotEmpty && result.first['householdNo'] != null) {
      return result.first['householdNo'] as int;
    }
    return null;
  }

  // Insert household linked to a user
  Future<int> insertHousehold(Map<String, dynamic> data, int userId) async {
    final db = await database;
    data['userId'] = userId;
    return await db.insert('households', data);
  }

  // Fetch households for current user
  Future<List<Map<String, dynamic>>> getUserHouseholds(int userId) async {
    final db = await database;
    return await db.query(
      'households',
      where: 'archived = 0 AND userId = ?',
      whereArgs: [userId],
      orderBy: 'householdNo ASC',
    );
  }

  // Get all households for current user
  Future<List<Map<String, dynamic>>> getAllHouseholds(int userId, {bool includeArchived = false}) async {
    final db = await database;
    final whereClause = includeArchived ? 'userId = ?' : 'archived = 0 AND userId = ?';
    return await db.query(
      'households',
      where: whereClause,
      whereArgs: [userId],
      orderBy: 'householdNo DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getHouseholdsByBarangay(String barangay, int userId, {bool includeArchived = false}) async {
    final db = await database;
    final whereClause = includeArchived
        ? 'barangay = ? AND userId = ?'
        : 'barangay = ? AND archived = 0 AND userId = ?';
    return await db.query(
      'households',
      where: whereClause,
      whereArgs: [barangay, userId],
      orderBy: 'householdNo DESC',
    );
  }

  Future<Map<String, dynamic>?> getHousehold(int id) async {
    final db = await database;
    final result = await db.query('households', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<void> updateHousehold(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('households', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> archiveHousehold(int id) async {
    final db = await database;
    await db.update('households', {'archived': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> unarchiveHousehold(int id) async {
    final db = await database;
    await db.update('households', {'archived': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteHouseholdPermanently(int id) async {
    final db = await database;
    await db.delete('households', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getArchivedHouseholds(int userId) async {
    final db = await database;
    return await db.query(
      'households',
      where: 'archived = 1 AND userId = ?',
      whereArgs: [userId],
      orderBy: 'householdNo DESC',
    );
  }
}