import 'package:flutter/material.dart';
import '../../../data/repositories/movie_repository.dart';
import '../../../domain/models/movie_model.dart';

class SearchViewModel extends ChangeNotifier {
  final MovieRepository _movieRepository;

  List<MovieModel> _movies = [];
  bool _isLoading = false;
  String? _errorMessage;

  SearchViewModel({required MovieRepository movieRepository}) : _movieRepository = movieRepository;

  List<MovieModel> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Keresés indítása a megadott kulcsszó alapján
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _movies = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _movies = await _movieRepository.searchMovies(query);
      if (_movies.isEmpty) {
        _errorMessage = "No movies found for '$query'.";
      }
    } catch (e) {
      _movies = [];
      _errorMessage = "Failed to load movies. Check your internet connection.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Keresési eredmények és hibák törlése (pl. kijelentkezéskor vagy lapváltáskor)
  void clearSearch() {
    _movies = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}