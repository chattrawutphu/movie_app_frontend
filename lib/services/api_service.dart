import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  final String baseUrl = 'http://localhost:3000';

  Future<List<Movie>> getMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/movies'));
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<Movie> getMovie(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/movies/$id'));
    
    if (response.statusCode == 200) {
      return Movie.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load movie');
    }
  }

  Future<Movie> createMovie(Map<String, dynamic> movieData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/movies'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(movieData),
    );
    
    if (response.statusCode == 201) {
      return Movie.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create movie');
    }
  }

  Future<Movie> updateMovie(int id, Map<String, dynamic> movieData) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/movies/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(movieData),
    );
    
    if (response.statusCode == 200) {
      return Movie.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update movie');
    }
  }

  Future<void> deleteMovie(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/movies/$id'));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete movie');
    }
  }
} 