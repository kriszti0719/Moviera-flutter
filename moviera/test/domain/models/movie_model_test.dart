import 'package:flutter_test/flutter_test.dart';
import 'package:moviera/domain/models/movie_model.dart';

void main() {
  group('MovieModel Unit Tests', () {
    // 1. Teszt: TMDB JSON parszolás ellenőrzése
    test('should correctly parse TMDB JSON into MovieModel', () {
      // Szimuláljuk a TMDB API-ból érkező Baby Driver JSON választ
      final Map<String, dynamic> fakeJson = {
        "id": 339403,
        "title": "Baby Driver",
        "poster_path": "/tYzFuYXmT8LOYASlFCkaPiAFAl0.jpg",
        "overview": "After being coerced into working for a crime boss...",
        "release_date": "2017-06-28",
        "vote_average": 7.443
      };

      // Végrehajtjuk a konverziót
      final movie = MovieModel.fromJson(fakeJson);

      // Ellenőrizzük az elvárt értékeket (Assertions)
      expect(movie.id, 339403);
      expect(movie.title, 'Baby Driver');
      expect(movie.posterPath, '/tYzFuYXmT8LOYASlFCkaPiAFAl0.jpg');
      expect(movie.releaseYear, '2017'); // A release_date első 4 karaktere kell legyen
      expect(movie.voteAverage, 7.443);
      expect(movie.isSeen, false); // Alapértelmezetten false kell legyen
    });

    // 2. Teszt: SQLite Map konverzió ellenőrzése (Mentéshez)
    test('should correctly convert MovieModel to SQLite Map', () {
      const movie = MovieModel(
        id: 123,
        title: "Test Movie",
        posterPath: "/path.jpg",
        overview: "Test Overview",
        releaseYear: "2026",
        voteAverage: 8.5,
        runtime: 120,
        isSeen: true,
      );

      final map = movie.toMap();

      // Ellenőrizzük, hogy az SQLite által elvárt formátum jött-e létre (a bool -> 1 vagy 0)
      expect(map['id'], 123);
      expect(map['title'], 'Test Movie');
      expect(map['runtime'], 120);
      expect(map['is_seen'], 1); // True esetén 1-nek kell lennie a DB-ben
    });

    // 3. Teszt: SQLite Map-ből Dart objektummá alakítás (Beolvasáshoz)
    test('should correctly parse SQLite Map into MovieModel', () {
      final Map<String, dynamic> fakeDbMap = {
        'id': 123,
        'title': 'Test Movie',
        'poster_path': '/path.jpg',
        'overview': 'Test Overview',
        'release_year': '2026',
        'vote_average': 8.5,
        'runtime': 120,
        'is_seen': 1 // 1-es integer képviseli a megtekintett állapotot
      };

      final movie = MovieModel.fromMap(fakeDbMap);

      expect(movie.id, 123);
      expect(movie.isSeen, true); // Az 1-esből true-nak kell lennie Dart oldalon
    });
  });
}