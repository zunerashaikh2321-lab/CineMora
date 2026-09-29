class ReviewModel {
  final String reviewId;
  final String userId;
  final String movieId;
  final String review;
  final String createdAt;

  ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.movieId,
    required this.review,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['review_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      movieId: json['movie_id']?.toString() ?? '',
      review: json['review']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'user_id': userId,
      'movie_id': movieId,
      'review': review,
      'created_at': createdAt,
    };
  }
}