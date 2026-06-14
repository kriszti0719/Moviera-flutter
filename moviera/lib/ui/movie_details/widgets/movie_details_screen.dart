import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/movie_model.dart';
import '../../watchlist/view_model/watchlist_view_model.dart';

class MovieDetailsScreen extends StatelessWidget {
  final MovieModel movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    // Figyeljük a WatchlistViewModel-t a reaktív felületfrissítéshez
    final watchlistViewModel = context.watch<WatchlistViewModel>();
    
    // Lekérjük a film legfrissebb állapotát a lokális adatbázisból
    final currentMovieState = watchlistViewModel.savedMovies.firstWhere(
      (m) => m.id == movie.id,
      orElse: () => movie,
    );

    final hasPoster = currentMovieState.posterPath != null && currentMovieState.posterPath!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentMovieState.title),
        centerTitle: true,
        // Az AppBar akciók közül eltávolítottuk a szem ikont, tiszta maradt a felső sáv
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasPoster)
              Image.network(
                'https://image.tmdb.org/t/p/w500${currentMovieState.posterPath}',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[800],
                  child: const Center(child: Icon(Icons.movie, size: 80)),
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.grey[800],
                child: const Center(child: Icon(Icons.movie, size: 80)),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentMovieState.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(label: Text(currentMovieState.releaseYear)),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: const Icon(Icons.star, color: Colors.amber, size: 16),
                        label: Text(currentMovieState.voteAverage.toStringAsFixed(1)),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: const Icon(Icons.access_time, size: 16),
                        label: Text(currentMovieState.runtime != null ? '${currentMovieState.runtime} min' : 'N/A'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // JAVÍTÁS: Anyanyelvi InkWell-be csomagolt, kattintható interaktív státusz sáv
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Átváltjuk a megtekintett státuszt az SQLite adatbázisban
                        watchlistViewModel.toggleMovieSeen(currentMovieState);
                        
                        // Kis visszajelzés a felhasználónak alul
                        ScaffoldMessenger.of(context).clearSnackBars(); // Eltünteti az előzőt, ha túl gyorsan nyomkodja
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              currentMovieState.isSeen 
                                  ? 'Marked as unwatched.' 
                                  : 'Marked as watched ("Seen it!").'
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Ink(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: currentMovieState.isSeen 
                              ? Colors.green.withOpacity(0.15) 
                              : Colors.blueGrey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: currentMovieState.isSeen ? Colors.green : Colors.blueGrey,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Középre igazítjuk az elemeket a sávban
                          children: [
                            Icon(
                              currentMovieState.isSeen ? Icons.check_circle : Icons.visibility_outlined,
                              color: currentMovieState.isSeen ? Colors.green : Colors.blueGrey,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              currentMovieState.isSeen ? 'Status: Watched' : 'Status: On Watchlist',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentMovieState.isSeen ? Colors.green[200] : Colors.blueGrey[100],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentMovieState.overview.isNotEmpty ? currentMovieState.overview : 'No description available.',
                    style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}