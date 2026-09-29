class MovieModel {
  final String movieId;
  final String movieName;
  final String moviePoster;
  final String genre;
  final String releaseDate;
  final String description;
  final String rating;
  final String isSuggested;
  final String createdAt;

  MovieModel({
    required this.movieId,
    required this.movieName,
    required this.moviePoster,
    required this.genre,
    required this.releaseDate,
    required this.description,
    required this.rating,
    required this.isSuggested,
    required this.createdAt,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      movieId: (json['movie_id'] ?? '').toString(),
      movieName: (json['movie_name'] ?? '').toString(),
      moviePoster: (json['movie_poster'] ?? '').toString(),
      genre: (json['genre'] ?? '').toString(),
      releaseDate: (json['release_date'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      rating: (json['rating'] ?? '').toString(),
      isSuggested: (json['is_suggested'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movie_id': movieId,
      'movie_name': movieName,
      'movie_poster': moviePoster,
      'genre': genre,
      'release_date': releaseDate,
      'description': description,
      'rating': rating,
      'is_suggested': isSuggested,
      'created_at': createdAt,
    };
  }
}