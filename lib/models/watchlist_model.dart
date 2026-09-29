class WatchlistModel {
  final String watchlistId;
  final String userId;
  final String movieId;
  final String addedAt;

  WatchlistModel({
    required this.watchlistId,
    required this.userId,
    required this.movieId,
    required this.addedAt,
  });

  factory WatchlistModel.fromJson(Map<String, dynamic> json) {
    return WatchlistModel(
      watchlistId: json['watchlist_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      movieId: json['movie_id']?.toString() ?? '',
      addedAt: json['added_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'watchlist_id': watchlistId,
      'user_id': userId,
      'movie_id': movieId,
      'added_at': addedAt,
    };
  }
}