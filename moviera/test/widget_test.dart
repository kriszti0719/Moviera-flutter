import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:moviera/ui/auth/view_model/auth_view_model.dart';
import 'package:moviera/ui/search/view_model/search_view_model.dart';
import 'package:moviera/ui/watchlist/view_model/watchlist_view_model.dart';
import 'package:moviera/ui/auth/widgets/login_screen.dart';
import 'ui/auth/auth_widgets_test.dart';
import 'ui/search/search_view_model_test.dart';
import 'ui/movie_details/details_widgets_test.dart'; // Importáljuk a HTTP fakes-t

void main() {
  setUpAll(() {
    HttpOverrides.global = FakeHttpOverrides();
  });

  testWidgets('Moviera base application smoke test', (WidgetTester tester) async {
    final fakeAuthRepo = FakeAuthRepository();
    final fakeMovieRepo = FakeMovieRepository();

    final authViewModel = AuthViewModel(authRepository: fakeAuthRepo);
    final searchViewModel = SearchViewModel(movieRepository: fakeMovieRepo);
    final watchlistViewModel = WatchlistViewModel(movieRepository: fakeMovieRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
          ChangeNotifierProvider<SearchViewModel>.value(value: searchViewModel),
          ChangeNotifierProvider<WatchlistViewModel>.value(value: watchlistViewModel),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Login to Moviera'), findsOneWidget);
  });
}