class MovieModel {
  final int id;
  final String title;
  final String? posterPath;
  final String overview;
  final String releaseYear;
  final double voteAverage;
  final int? runtime; // Opcionális, mivel kereséskor nem, csak mentéskor/részletezéskor érhető el
  final bool isSeen;  // A te egyedi funkcionális módosítód ("Seen it" állapot)

  const MovieModel({
    required this.id,
    required this.title,
    this.posterPath,
    required this.overview,
    required this.releaseYear,
    required this.voteAverage,
    this.runtime,
    this.isSeen = false,
  });

  /// Másoló függvény, ami elengedhetetlen az immutabilitás megőrzéséhez az állapotfrissítések során
  MovieModel copyWith({
    int? id,
    String? title,
    String? posterPath,
    String? overview,
    String? releaseYear,
    double? voteAverage,
    int? runtime,
    bool? isSeen,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      overview: overview ?? this.overview,
      releaseYear: releaseYear ?? this.releaseYear,
      voteAverage: voteAverage ?? this.voteAverage,
      runtime: runtime ?? this.runtime,
      isSeen: isSeen ?? this.isSeen,
    );
  }

  /// TMDB API JSON válaszok feldolgozására szolgáló gyári konstruktor
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    // Biztonságosan kinyerjük az évszámot a "2017-06-28" formátumból, felkészülve az üres értékekre is
    String year = 'N/A';
    final releaseDate = json['release_date'] as String?;
    if (releaseDate != null && releaseDate.length >= 4) {
      year = releaseDate.substring(0, 4);
    }

    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown Title',
      posterPath: json['poster_path'] as String?,
      overview: json['overview'] as String? ?? '',
      releaseYear: year,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      runtime: json['runtime'] as int?, // null marad, ha a keresési listából jön az adat
      isSeen: false, // Alapértelmezetten hamis az API-ból érkező új filmeknél
    );
  }

  /// sqflite (SQLite) adatbázisból beolvasott sorok konvertálása Dart objektummá
  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      id: map['id'] as int,
      title: map['title'] as String,
      posterPath: map['poster_path'] as String?,
      overview: map['overview'] as String,
      releaseYear: map['release_year'] as String,
      voteAverage: map['vote_average'] as double,
      runtime: map['runtime'] as int?,
      isSeen: (map['is_seen'] as int) == 1, // Az SQLite az egészeket (0 vagy 1) preferálja a bool helyett
    );
  }

  /// Dart objektum konvertálása Map struktúrává az sqflite adatbázisba történő biztonságos mentéshez
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'overview': overview,
      'release_year': releaseYear,
      'vote_average': voteAverage,
      'runtime': runtime,
      'is_seen': isSeen ? 1 : 0, // A logikai értéket integerként (1 vagy 0) tároljuk az adatbázisban
    };
  }
}