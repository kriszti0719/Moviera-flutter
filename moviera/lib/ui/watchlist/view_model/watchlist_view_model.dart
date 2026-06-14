import 'package:flutter/material.dart';
import '../../../data/repositories/movie_repository.dart';
import '../../../domain/models/movie_model.dart';

class WatchlistViewModel extends ChangeNotifier {
  final MovieRepository _movieRepository;

  List<MovieModel> _savedMovies = [];
  bool _isLoading = false;

  WatchlistViewModel({required MovieRepository movieRepository}) : _movieRepository = movieRepository;

  List<MovieModel> get savedMovies => _savedMovies;
  bool get isLoading => _isLoading;

  /// Betölti az összes elmentett offline filmet az adatbázisból
  Future<void> loadWatchlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      _savedMovies = await _movieRepository.getSavedWatchlist();
    } catch (_) {
      _savedMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Film hozzáadása a Watchlist-hez a keresőből
  Future<void> addToWatchlist(MovieModel movie) async {
    await _movieRepository.saveMovieToWatchlist(movie);
    await loadWatchlist(); // Lista újratöltése
  }

  /// Film eltávolítása a Watchlist-ből
  Future<void> removeFromWatchlist(int movieId) async {
    await _movieRepository.removeMovieFromWatchlist(movieId);
    await loadWatchlist(); // Lista újratöltése
  }

  /// "Seen it" pipa állapotának átváltása (Toggle)
  Future<void> toggleMovieSeen(MovieModel movie) async {
    await _movieRepository.toggleSeenStatus(movie.id, movie.isSeen);
    await loadWatchlist(); // Lista újratöltése
  }

  /// Segédfüggvény a UI-nak, hogy ellenőrizze, el van-e mentve egy film
  Future<bool> isSaved(int movieId) async {
    return await _movieRepository.isMovieSaved(movieId);
  }
}