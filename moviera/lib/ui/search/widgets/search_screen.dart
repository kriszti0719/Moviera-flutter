import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/search_view_model.dart';
import '../../watchlist/view_model/watchlist_view_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchViewModel = context.watch<SearchViewModel>();
    final watchlistViewModel = context.watch<WatchlistViewModel>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter movie title...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    searchViewModel.search(_searchController.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                searchViewModel.search(value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: searchViewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : searchViewModel.errorMessage != null
                      ? Center(
                          child: Text(
                            searchViewModel.errorMessage!,
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: searchViewModel.movies.length,
                          itemBuilder: (context, index) {
                            final movie = searchViewModel.movies[index];
                            final hasPoster = movie.posterPath != null && movie.posterPath!.isNotEmpty;

                            // Megnézzük, hogy ez a konkrét film el van-e már mentve az offline DB-ben
                            final isAlreadySaved = watchlistViewModel.savedMovies.any((m) => m.id == movie.id);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: hasPoster
                                    ? Image.network(
                                        'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                                        width: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.movie, size: 50),
                                      )
                                    : const Icon(Icons.movie, size: 50),
                                title: Text(
                                  movie.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${movie.releaseYear} • ⭐ ${movie.voteAverage.toStringAsFixed(1)}',
                                ),
                                // MENTÉS GOMB: Ha már el van mentve, egy teli ikont mutat, ha nincs, egy mentés gombot
                                trailing: IconButton(
                                  icon: Icon(
                                    isAlreadySaved ? Icons.bookmark : Icons.bookmark_border,
                                    color: isAlreadySaved ? Colors.amber : null,
                                  ),
                                  onPressed: () {
                                    if (isAlreadySaved) {
                                      watchlistViewModel.removeFromWatchlist(movie.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${movie.title} removed from watchlist.')),
                                      );
                                    } else {
                                      watchlistViewModel.addToWatchlist(movie);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${movie.title} saved offline!')),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}