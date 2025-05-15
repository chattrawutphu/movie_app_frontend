import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Movie>> futureMovies;

  @override
  void initState() {
    super.initState();
    futureMovies = apiService.getMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Movie App'),
      actions: [
        IconButton(
          icon: const Icon(Icons.admin_panel_settings),
          onPressed: () {
            Navigator.pushNamed(context, '/admin');
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<Movie>>(
      future: futureMovies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        } else if (snapshot.hasError) {
          return ErrorMessage(error: snapshot.error);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyStateMessage();
        } else {
          return _buildMovieGrid(snapshot.data!);
        }
      },
    );
  }

  Widget _buildMovieGrid(List<Movie> movies) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieCard(movie: movie);
      },
    );
  }
}

// Widget ย่อยสำหรับ Loading
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// Widget ย่อยสำหรับข้อผิดพลาด
class ErrorMessage extends StatelessWidget {
  final Object? error;
  
  const ErrorMessage({Key? key, this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Error: $error'));
  }
}

// Widget ย่อยสำหรับข้อมูลว่าง
class EmptyStateMessage extends StatelessWidget {
  const EmptyStateMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No movies available'));
  }
}

// Widget ย่อยสำหรับการ์ดภาพยนตร์
class MovieCard extends StatelessWidget {
  final Movie movie;
  
  const MovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Card(
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPosterImage(),
            _buildMovieInfo(),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movieId: movie.id),
      ),
    );
  }

  Widget _buildPosterImage() {
    return Expanded(
      child: movie.posterUrl != null
          ? Image.network(
              movie.posterUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.movie, size: 50)),
            )
          : Container(
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.movie, size: 50)),
            ),
    );
  }

  Widget _buildMovieInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              Text(' ${movie.rating.toStringAsFixed(1)}'),
              Text(' • ${movie.releaseYear}'),
            ],
          ),
        ],
      ),
    );
  }
} 