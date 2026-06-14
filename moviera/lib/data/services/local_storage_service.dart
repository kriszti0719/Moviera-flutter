import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/models/movie_model.dart';

class LocalStorageService {
  static const String _dbName = 'moviera_database.db';
  static const String _tableName = 'watchlist';
  Database? _database;

  /// Szingleton vagy belső inicializáció az adatbázis eléréséhez
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Kinyerjük a platformspecifikus adatbázis útvonalat
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    // Megnyitjuk az adatbázist és létrehozzuk a táblát, ha még nem létezik
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            poster_path TEXT,
            overview TEXT NOT NULL,
            release_year TEXT NOT NULL,
            vote_average REAL NOT NULL,
            runtime INTEGER,
            is_seen INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  /// 1. Összes elmentett film lekérése az adatbázisból
  Future<List<MovieModel>> getWatchlist() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    
    // A Map listát visszaalakítjuk a tiszta domain modell listánkká
    return maps.map((movieMap) => MovieModel.fromMap(movieMap)).toList();
  }

  /// 2. Új film elmentése a Watchlist-be
  Future<void> insertMovie(MovieModel movie) async {
    final db = await database;
    await db.insert(
      _tableName,
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Ha már létezik, felülírja
    );
  }

  /// 3. Film törlése a Watchlist-ből
  Future<void> deleteMovie(int movieId) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [movieId],
    );
  }

  /// 4. "Seen it" (Megtekintett) státusz frissítése az adatbázisban
  Future<void> updateMovieSeenStatus(int movieId, bool isSeen) async {
    final db = await database;
    await db.update(
      _tableName,
      {'is_seen': isSeen ? 1 : 0},
      where: 'id = ?',
      whereArgs: [movieId],
    );
  }

  /// Belenézünk, hogy egy konkrét film el van-e már mentve (a keresőhöz/részletekhez)
  Future<bool> isMovieSaved(int movieId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [movieId],
    );
    return maps.isNotEmpty;
  }
}