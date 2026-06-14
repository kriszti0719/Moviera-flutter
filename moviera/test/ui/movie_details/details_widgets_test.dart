import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:moviera/ui/movie_details/widgets/movie_details_screen.dart';
import 'package:moviera/ui/watchlist/view_model/watchlist_view_model.dart';
import 'package:moviera/domain/models/movie_model.dart';
import '../search/search_view_model_test.dart'; // Beimportáljuk a működő FakeMovieRepository-t

// Szimulált HTTP kliens, ami megakadályozza az Image.network hálózati hibáit a teszt alatt
class FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => 0;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return const Stream<List<int>>.empty().listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class FakeWatchlistViewModel extends WatchlistViewModel {
  // JAVÍTÁS: Nem null-t adunk át, hanem bekérjük a szabályos repository-t
  FakeWatchlistViewModel({required super.movieRepository});
  
  @override
  List<MovieModel> get savedMovies => [
    const MovieModel(
      id: 550,
      title: "Fight Club",
      posterPath: "/fightclub.jpg",
      overview: "An insomniac office worker...",
      releaseYear: "1999",
      voteAverage: 8.4,
      isSeen: false,
    )
  ];
  
  @override
  bool get isLoading => false;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = FakeHttpOverrides();
  });

  testWidgets('MovieDetailsScreen layout tracking bar verification test', (WidgetTester tester) async {
    // JAVÍTÁS: Példányosítjuk a szabályos FakeMovieRepository-t, és azt adjuk oda a ViewModel-nek
    final fakeMovieRepo = FakeMovieRepository();
    final fakeWatchlistVM = FakeWatchlistViewModel(movieRepository: fakeMovieRepo);

    const testMovie = MovieModel(
      id: 550,
      title: "Fight Club",
      posterPath: "/fightclub.jpg",
      overview: "An insomniac office worker...",
      releaseYear: "1999",
      voteAverage: 8.4,
      isSeen: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<WatchlistViewModel>.value(
          value: fakeWatchlistVM,
          child: const MovieDetailsScreen(movie: testMovie),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Fight Club'), findsWidgets);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Status: On Watchlist'), findsOneWidget);
  });
}