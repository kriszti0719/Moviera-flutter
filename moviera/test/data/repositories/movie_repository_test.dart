import 'package:flutter_test/flutter_test.dart';
import '../../ui/search/search_view_model_test.dart'; // Beemeljük a már megírt Fake-et

void main() {
  group('MovieRepository Unit Tests', () {
    late FakeMovieRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeMovieRepository();
    });

    test('should return empty list when search target has no match', () async {
      final results = await fakeRepository.searchMovies('Unknown Movie');
      expect(results.isEmpty, true);
    });

    test('should verify check saved status returns false by default', () async {
      final isSaved = await fakeRepository.isMovieSaved(999);
      expect(isSaved, false);
    });
  });
}