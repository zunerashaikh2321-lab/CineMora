class RatingModel {
  final String ratingId;
  final String userId;
  final String movieId;
  final String rating;
  final String createdAt;

  RatingModel({
    required this.ratingId,
    required this.userId,
    required this.movieId,
    required this.rating,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      ratingId: json['rating_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      movieId: json['movie_id']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating_id': ratingId,
      'user_id': userId,
      'movie_id': movieId,
      'rating': rating,
      'created_at': createdAt,
    };
  }
}