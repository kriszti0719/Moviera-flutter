import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/movie_model.dart';

class TmdbApiService {
  // Alap URL az API eléréséhez
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  
  // A dokumentációdból kimásolt egyedi hitelesítési token
  static const String _bearerToken = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjMzczYTZlMDA3Njc3NDdhZmVlZDdiNDEzYjNlZjI3YSIsIm5iZiI6MTY4NDY5MDM4OS4zOTEsInN1YiI6IjY0NmE1NWQ1YzM1MTRjMDExZGNiNmEwNSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.zhCFlWQiYMuTK-FdpOkFvEerLmuZImTn4Gf2RzJzZDI';

  // Közös fejléc (Header) a hitelesítéshez és a JSON formátum elfogadásához
  Map<String, String> get _headers => {
        'accept': 'application/json',
        'Authorization': 'Bearer $_bearerToken',
      };

  /// 1. Filmek keresése kulcsszó alapján
  Future<List<MovieModel>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];

    // Biztonságosan kódoljuk a keresőszót az URL-be (pl. szóközök -> %20)
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('$_baseUrl/search/movie?query=$encodedQuery&include_adult=false&language=en-US&page=1');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] as List<dynamic>;

        // A JSON listát leképezzük a tiszta domain MovieModel listánkká
        return results.map((movieJson) => MovieModel.fromJson(movieJson)).toList();
      } else {
        throw Exception('Failed to search movies. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during movie search: $e');
    }
  }

  /// 2. Konkrét film részletes adatainak lekérése (id alapján a játékidőhöz)
  Future<MovieModel> getMovieDetails(int movieId) async {
    final url = Uri.parse('$_baseUrl/movie/$movieId?language=en-US');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> movieJson = json.decode(response.body);
        
        // A részletes végpont visszadja a "runtime" mezőt is, a gyári fromJson ezt is feldolgozza
        return MovieModel.fromJson(movieJson);
      } else {
        throw Exception('Failed to fetch movie details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during fetching movie details: $e');
    }
  }
}