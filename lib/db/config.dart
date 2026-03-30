// lib/db/config.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/household.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('household.db');
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
      CREATE TABLE households (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        householdNo INTEGER,
        barangay TEXT,
        occupation TEXT,
        education TEXT,
        zone INTEGER,
        householdHead TEXT,
        male INTEGER,
        female INTEGER,
        total INTEGER,
        families INTEGER,
        pregnant INTEGER,
        lactating INTEGER,
        infant0to5 INTEGER,
        infant6to11 INTEGER,
        infant12to23 INTEGER,
        infant24to59 INTEGER,
        underweightSevere INTEGER,
        underweight INTEGER,
        normal INTEGER,
        wastedSevere INTEGER,
        wasted INTEGER,
        overweight INTEGER,
        obese INTEGER,
        stuntedSevere INTEGER,
        stunted INTEGER,
        toilet TEXT,
        water TEXT,
        food TEXT,
        iodizedSalt INTEGER,
        ifr INTEGER,
        archived INTEGER DEFAULT 0
      )
    ''');
  }

  // ✅ INSERT
  Future<int> insertHousehold(Household household) async {
    final db = await instance.database;
    return await db.insert('households', household.toMap());
  }

  // ✅ GET ALL (not archived)
  Future<List<Household>> getAllHouseholds() async {
    final db = await instance.database;
    final result = await db.query(
      'households',
      where: 'archived = ?',
      whereArgs: [0],
    );
    return result.map((e) => Household.fromMap(e)).toList();
  }

  // ✅ GET BY ID
  Future<Household?> getHousehold(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'households',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Household.fromMap(result.first);
    }
    return null;
  }

  // ✅ UPDATE
  Future<int> updateHousehold(Household household) async {
    final db = await instance.database;
    return await db.update(
      'households',
      household.toMap(),
      where: 'id = ?',
      whereArgs: [household.id],
    );
  }

  // ✅ DELETE
  Future<int> deleteHousehold(int id) async {
    final db = await instance.database;
    return await db.delete(
      'households',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ ARCHIVE
  Future<int> archive(int id) async {
    final db = await instance.database;
    return await db.update(
      'households',
      {'archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ FIXED: GET LAST HOUSEHOLD NUMBER (INSIDE CLASS ONLY)
  Future<int> getLastHouseholdNo() async {
    final db = await instance.database;

    final result = await db.rawQuery(
      'SELECT MAX(householdNo) as lastNo FROM households',
    );

    if (result.isNotEmpty && result.first['lastNo'] != null) {
      return result.first['lastNo'] as int;
    }

    return 0;
  }
}