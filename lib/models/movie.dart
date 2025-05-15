class Movie {
  final int id;
  final String title;
  final String description;
  final int releaseYear;
  final int duration;
  final String genre;
  final String? director;
  final String? cast;
  final double rating;
  final String? posterUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.releaseYear,
    required this.duration,
    required this.genre,
    this.director,
    this.cast,
    required this.rating,
    this.posterUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      releaseYear: json['releaseYear'],
      duration: json['duration'],
      genre: json['genre'],
      director: json['director'],
      cast: json['cast'],
      rating: json['rating']?.toDouble() ?? 0.0,
      posterUrl: json['posterUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'releaseYear': releaseYear,
      'duration': duration,
      'genre': genre,
      'director': director,
      'cast': cast,
      'rating': rating,
      'posterUrl': posterUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 