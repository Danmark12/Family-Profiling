// lib/db/config.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

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

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE households(
id INTEGER PRIMARY KEY AUTOINCREMENT,
householdNo INTEGER,

zone TEXT,
barangay TEXT,

fourPs INTEGER,
indigenousPeople INTEGER,
iodizedSalt INTEGER,

fatherName TEXT NULL,
fatherOccupation TEXT NULL,
fatherEducation TEXT NULL,

motherName TEXT NULL,
motherOccupation TEXT NULL,
motherEducation TEXT NULL,

male INTEGER,
female INTEGER,
total INTEGER,
families INTEGER,
fullyImmunized INTEGER,

exclusive INTEGER,
mixed INTEGER,
bottleFed INTEGER,
complementary INTEGER,

preg19 INTEGER,
preg20 INTEGER,
lactating INTEGER,

infant0to5 INTEGER,
infant6to11 INTEGER,
child12to23 INTEGER,
child24to59 INTEGER,
age5to9 INTEGER,
age10to19 INTEGER,
age20to59 INTEGER,
age60above INTEGER,
pwd INTEGER,

severelyUnderweight INTEGER,
underweight INTEGER,
normal INTEGER,
severelyWasted INTEGER,
wasted INTEGER,
overweight INTEGER,
obese INTEGER,
severelyStunted INTEGER,
stunted INTEGER,

toilet TEXT,
garbage TEXT,
water TEXT,
food TEXT,
dwellingType TEXT,

archived INTEGER DEFAULT 0
)
''');
  }

  // ✅ GET LAST HOUSEHOLD NUMBER
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

  // ✅ INSERT
  Future<int> insertHousehold(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('households', data);
  }

  // ✅ GET ALL HOUSEHOLDS (optionally include archived)
  Future<List<Map<String, dynamic>>> getAllHouseholds({bool includeArchived = false}) async {
    final db = await database;
    final whereClause = includeArchived ? null : 'archived = 0';
    return await db.query(
      'households',
      where: whereClause,
      orderBy: 'householdNo DESC',
    );
  }

  // ✅ GET SINGLE HOUSEHOLD
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

  // ✅ UPDATE HOUSEHOLD
  Future<void> updateHousehold(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update(
      'households',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ ARCHIVE HOUSEHOLD (soft delete)
  Future<void> archiveHousehold(int id) async {
    final db = await database;
    await db.update(
      'households',
      {'archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ UNARCHIVE HOUSEHOLD
  Future<void> unarchiveHousehold(int id) async {
    final db = await database;
    await db.update(
      'households',
      {'archived': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ DELETE HOUSEHOLD PERMANENTLY
  Future<void> deleteHouseholdPermanently(int id) async {
    final db = await database;
    await db.delete(
      'households',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ GET ALL ARCHIVED HOUSEHOLDS
  Future<List<Map<String, dynamic>>> getArchivedHouseholds() async {
    final db = await database;
    return await db.query(
      'households',
      where: 'archived = 1',
      orderBy: 'householdNo DESC',
    );
  }
}