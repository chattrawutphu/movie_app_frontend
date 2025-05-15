import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final ApiService apiService = ApiService();
  late Future<Movie> futureMovie;

  @override
  void initState() {
    super.initState();
    futureMovie = apiService.getMovie(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Details'),
      ),
      body: FutureBuilder<Movie>(
        future: futureMovie,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Movie not found'));
          } else {
            final movie = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  movie.posterUrl != null
                      ? Image.network(
                          movie.posterUrl!,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: double.infinity,
                            height: 300,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.movie, size: 100)),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.movie, size: 100)),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(movie.genre),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Text(' ${movie.rating.toStringAsFixed(1)}'),
                            const SizedBox(width: 8),
                            Text('${movie.duration} min'),
                            const SizedBox(width: 8),
                            Text('${movie.releaseYear}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(movie.description),
                        if (movie.director != null && movie.director!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Director',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(movie.director!),
                        ],
                        if (movie.cast != null && movie.cast!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Cast',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(movie.cast!),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
} 