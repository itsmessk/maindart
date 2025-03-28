import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/place.dart';

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
    String path = join(await getDatabasesPath(), 'travelmate.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites(
        id TEXT PRIMARY KEY,
        name TEXT,
        address TEXT,
        latitude REAL,
        longitude REAL,
        imageUrl TEXT,
        type TEXT,
        rating REAL,
        isFavorite INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE search_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT,
        timestamp INTEGER
      )
    ''');
  }

  // Favorites methods
  Future<int> addFavorite(Place place) async {
    Database db = await database;
    return await db.insert(
      'favorites',
      place.copyWith(isFavorite: true).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeFavorite(String id) async {
    Database db = await database;
    return await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Place>> getFavorites() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) {
      return Place.fromMap(maps[i]);
    });
  }

  Future<bool> isFavorite(String id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  // Search history methods
  Future<int> addSearchQuery(String query) async {
    Database db = await database;
    return await db.insert(
      'search_history',
      {
        'query': query,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<List<String>> getSearchHistory() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'search_history',
      orderBy: 'timestamp DESC',
      limit: 10,
    );
    return List.generate(maps.length, (i) {
      return maps[i]['query'] as String;
    });
  }

  Future<int> clearSearchHistory() async {
    Database db = await database;
    return await db.delete('search_history');
  }
}
