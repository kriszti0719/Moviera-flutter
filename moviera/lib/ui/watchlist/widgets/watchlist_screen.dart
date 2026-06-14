import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/watchlist_view_model.dart';
import '../../movie_details/widgets/movie_details_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlistViewModel = context.watch<WatchlistViewModel>();

    return Scaffold(
      body: watchlistViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : watchlistViewModel.savedMovies.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie_creation_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Your watchlist is empty.',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Go to the Search tab to find and save your favorite movies offline!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: watchlistViewModel.savedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = watchlistViewModel.savedMovies[index];
                    final hasPoster = movie.posterPath != null && movie.posterPath!.isNotEmpty;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      elevation: 4,
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: movie.isSeen ? TextDecoration.lineThrough : null,
                            color: movie.isSeen ? Colors.grey : null,
                          ),
                        ),
                        // Ha meg van tekintve, kap egy kis címkét a felirat mellé
                        subtitle: Text(
                          movie.isSeen 
                              ? '${movie.releaseYear} • ⭐ ${movie.voteAverage.toStringAsFixed(1)} (Watched)'
                              : '${movie.releaseYear} • ⭐ ${movie.voteAverage.toStringAsFixed(1)}'
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            watchlistViewModel.removeFromWatchlist(movie.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${movie.title} removed from watchlist.')),
                            );
                          },
                          tooltip: 'Remove',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailsScreen(movie: movie),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}