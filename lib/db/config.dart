// lib/db/config.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/household.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'census.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE households(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        householdNo INTEGER,
        name TEXT,
        purok TEXT,
        occupation TEXT,
        education TEXT,
        male INTEGER,
        female INTEGER,
        total INTEGER,
        pregnant INTEGER,
        lactating INTEGER,
        su INTEGER,
        uw INTEGER,
        nw INTEGER,
        sw INTEGER,
        w INTEGER,
        ow INTEGER,
        ob INTEGER,
        ss INTEGER,
        st INTEGER,
        inf0_5 INTEGER,
        inf6_11 INTEGER,
        pre0_23 INTEGER,
        pre12_59 INTEGER,
        pre24_59 INTEGER,
        breastfed INTEGER,
        dewormed INTEGER,
        fic INTEGER,
        iodized TEXT,
        eatery TEXT,
        archived INTEGER DEFAULT 0
      )
    ''');
  }

  // INSERT HOUSEHOLD
  Future<int> insert(Household hh) async {
    final db = await database;
    return await db.insert('households', hh.toMap());
  }

  // GET ALL HOUSEHOLDS (only not archived)
  Future<List<Household>> getAllHouseholds() async {
    final db = await database;
    final result = await db.query(
      'households',
      where: 'archived = ?',
      whereArgs: [0],
      orderBy: 'id DESC',
    );

    return result.map((json) => Household.fromMap(json)).toList();
  }

  // ARCHIVE HOUSEHOLD
  Future<int> archive(int id) async {
    final db = await database;
    return await db.update(
      'households',
      {'archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // GET BY ID (optional)
  Future<Household?> getById(int id) async {
    final db = await database;
    final result = await db.query('households', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) return Household.fromMap(result.first);
    return null;
  }
}