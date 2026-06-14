// Koordinálja az adatot a TMDB API és sqflite cache között
import '../../domain/models/movie_model.dart';
import '../services/tmdb_api_service.dart';
import '../services/local_storage_service.dart';

class MovieRepository {
  final TmdbApiService _apiService;
  final LocalStorageService _localStorageService;

  MovieRepository({
    required TmdbApiService apiService,
    required LocalStorageService localStorageService,
  })  : _apiService = apiService,
        _localStorageService = localStorageService;

  /// Filmek keresése az API szolgáltatáson keresztül
  Future<List<MovieModel>> searchMovies(String query) async {
    return await _apiService.searchMovies(query);
  }

  /// Egy konkrét film részletes adatainak lekérése (id alapján)
  Future<MovieModel> getMovieDetails(int movieId) async {
    return await _apiService.getMovieDetails(movieId);
  }
/// --- HELYI ADATBÁZIS MŰVELETEK ---

  Future<List<MovieModel>> getSavedWatchlist() async {
    return await _localStorageService.getWatchlist();
  }

  /// Film elmentése: lekérjük a részletes adatokat az API-ból a játékidő miatt, majd mentünk
  Future<void> saveMovieToWatchlist(MovieModel movieSummary) async {
    try {
      // Lekérjük a részletes adatot, hátha van benne runtime (játékidő)
      final detailedMovie = await _apiService.getMovieDetails(movieSummary.id);
      
      // Megőrizzük az eredeti summary adatait, de befrissítjük a játékidőt
      final movieToSave = movieSummary.copyWith(runtime: detailedMovie.runtime);
      await _localStorageService.insertMovie(movieToSave);
    } catch (_) {
      // Ha nincs net a részletes lekéréshez, elmentjük a meglévő alap adatokat
      await _localStorageService.insertMovie(movieSummary);
    }
  }

  Future<void> removeMovieFromWatchlist(int movieId) async {
    await _localStorageService.deleteMovie(movieId);
  }

  Future<void> toggleSeenStatus(int movieId, bool currentStatus) async {
    await _localStorageService.updateMovieSeenStatus(movieId, !currentStatus);
  }

  Future<bool> isMovieSaved(int movieId) async {
    return await _localStorageService.isMovieSaved(movieId);
  }
}