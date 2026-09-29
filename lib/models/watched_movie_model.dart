class WatchedMovieModel {
  final String watchedId;
  final String userId;
  final String movieId;
  final String watchedAt;

  WatchedMovieModel({
    required this.watchedId,
    required this.userId,
    required this.movieId,
    required this.watchedAt,
  });

  factory WatchedMovieModel.fromJson(Map<String, dynamic> json) {
    return WatchedMovieModel(
      watchedId: json['watched_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      movieId: json['movie_id']?.toString() ?? '',
      watchedAt: json['watched_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'watched_id': watchedId,
      'user_id': userId,
      'movie_id': movieId,
      'watched_at': watchedAt,
    };
  }
}