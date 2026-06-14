import 'package:flutter_test/flutter_test.dart';
import 'package:moviera/ui/search/view_model/search_view_model.dart';
import 'package:moviera/data/repositories/movie_repository.dart';
import 'package:moviera/domain/models/movie_model.dart';

// Szimulált (Fake) Repository a hálózati réteg kiiktatására
class FakeMovieRepository implements MovieRepository {
  bool throwError = false;
  List<MovieModel> fakeResults = [];

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    if (throwError) throw Exception("Network Error");
    if (query == "Baby Driver") {
      return fakeResults;
    }
    return [];
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) async => throw UnimplementedError();

  @override
  Future<MovieModel> getMovieDetailsFromApi(int movieId) async => throw UnimplementedError();
  
  @override
  Future<List<MovieModel>> getSavedWatchlist() async => [];
  
  @override
  Future<void> saveMovieToWatchlist(MovieModel movie) async {}
  
  @override
  Future<void> removeMovieFromWatchlist(int movieId) async {}
  
  @override
  Future<void> toggleSeenStatus(int movieId, bool currentStatus) async {}
  
  @override
  Future<bool> isMovieSaved(int movieId) async => false;
}

void main() {
  group('SearchViewModel Unit Tests', () {
    late FakeMovieRepository fakeRepository;
    late SearchViewModel viewModel;

    setUp(() {
      fakeRepository = FakeMovieRepository();
      viewModel = SearchViewModel(movieRepository: fakeRepository);
    });

    test('should start with an empty movie list and no errors', () {
      expect(viewModel.movies.isEmpty, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('should populate movies list successfully when query matches data', () async {
      fakeRepository.fakeResults = [
        const MovieModel(id: 1, title: "Baby Driver", overview: "...", releaseYear: "2017", voteAverage: 7.4)
      ];

      final futureSearch = viewModel.search("Baby Driver");
      expect(viewModel.isLoading, true);

      await futureSearch;

      expect(viewModel.isLoading, false);
      expect(viewModel.movies.length, 1);
      expect(viewModel.movies.first.title, "Baby Driver");
      expect(viewModel.errorMessage, null);
    });

    test('should set errorMessage when no movies are found', () async {
      await viewModel.search("Non Existing Movie");

      expect(viewModel.movies.isEmpty, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, "No movies found for 'Non Existing Movie'.");
    });

    test('should set generic error message when repository throws an exception', () async {
      fakeRepository.throwError = true;

      await viewModel.search("Baby Driver");

      expect(viewModel.movies.isEmpty, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, "Failed to load movies. Check your internet connection.");
    });
  });
}