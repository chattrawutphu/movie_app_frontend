import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'edit_movie_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Movie>> futureMovies;

  @override
  void initState() {
    super.initState();
    _refreshMovies();
  }

  void _refreshMovies() {
    setState(() {
      futureMovies = apiService.getMovies();
    });
  }

  Future<void> _deleteMovie(int id) async {
    try {
      await apiService.deleteMovie(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie deleted successfully')),
      );
      _refreshMovies();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting movie: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Movies Management'),
      ),
      body: FutureBuilder<List<Movie>>(
        future: futureMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No movies available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final movie = snapshot.data![index];
                return ListTile(
                  leading: movie.posterUrl != null
                      ? Image.network(
                          movie.posterUrl!,
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(
                                width: 50,
                                height: 75,
                                color: Colors.grey[300],
                                child: const Icon(Icons.movie),
                              ),
                        )
                      : Container(
                          width: 50,
                          height: 75,
                          color: Colors.grey[300],
                          child: const Icon(Icons.movie),
                        ),
                  title: Text(movie.title),
                  subtitle: Text('${movie.releaseYear} • ${movie.genre}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMovieScreen(movie: movie),
                            ),
                          );
                          if (result == true) {
                            _refreshMovies();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Movie'),
                              content: Text('Are you sure you want to delete "${movie.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('CANCEL'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteMovie(movie.id);
                                  },
                                  child: const Text('DELETE'),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditMovieScreen(),
            ),
          );
          if (result == true) {
            _refreshMovies();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 