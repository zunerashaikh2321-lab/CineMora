import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../models/review_model.dart';
import '../services/api_service.dart';
import '../utils/session_manager.dart';

class MovieDetailsPage extends StatefulWidget {
  final String movieId;

  const MovieDetailsPage({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  final ApiService _apiService = ApiService();

  MovieModel? _movie;
  List<ReviewModel> _reviews = [];

  bool _isLoading = true;
  bool _isWatchlisted = false;
  bool _isWatched = false;
  bool _isSubmittingReview = false;

  double _selectedRating = 0;

  // ============================================================
  // REVIEW CONTROLLER
  // ============================================================

  final TextEditingController _reviewController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD MOVIE DETAILS
  // ============================================================

  Future<void> _loadMovieDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final movieResponse =
      await _apiService.getMovie(widget.movieId);

      final reviewResponse =
      await _apiService.getReviews(widget.movieId);

      if (movieResponse is Map &&
          movieResponse['status']?.toString().toLowerCase() ==
              'success') {
        final data = movieResponse['data'];

        if (data is Map) {
          _movie = MovieModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
      }

      if (reviewResponse is Map &&
          reviewResponse['status']?.toString().toLowerCase() ==
              'success') {
        final data = reviewResponse['data'];

        if (data is List) {
          _reviews = data
              .map(
                (item) => ReviewModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Movie details error: $e');
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // ============================================================
  // ADD TO WATCHLIST
  // ============================================================

  Future<void> _addToWatchlist() async {
    final userId = await SessionManager.getUserId();

    if (userId == null || userId.isEmpty) {
      _showMessage('Please login first');
      return;
    }

    try {
      final response = await _apiService.addWatchlist(
        userId: userId,
        movieId: widget.movieId,
      );

      if (!mounted) return;

      if (response is Map &&
          response['status']?.toString().toLowerCase() ==
              'success') {
        setState(() {
          _isWatchlisted = true;
        });

        _showMessage('Added to watchlist');
      } else {
        _showMessage(
          response is Map
              ? response['message']?.toString() ??
              'Unable to add to watchlist'
              : 'Unable to add to watchlist',
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Something went wrong');
      }
    }
  }

  // ============================================================
  // MARK AS WATCHED
  // ============================================================

  Future<void> _markAsWatched() async {
    final userId = await SessionManager.getUserId();

    if (userId == null || userId.isEmpty) {
      _showMessage('Please login first');
      return;
    }

    try {
      final response = await _apiService.markWatched(
        userId: userId,
        movieId: widget.movieId,
      );

      if (!mounted) return;

      if (response is Map &&
          response['status']?.toString().toLowerCase() ==
              'success') {
        setState(() {
          _isWatched = true;
        });

        _showMessage('Marked as watched');
      } else {
        _showMessage(
          response is Map
              ? response['message']?.toString() ??
              'Unable to mark movie'
              : 'Unable to mark movie',
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Something went wrong');
      }
    }
  }

  // ============================================================
  // SUBMIT RATING
  // ============================================================

  Future<void> _submitRating() async {
    if (_selectedRating <= 0) {
      _showMessage('Please select a rating');
      return;
    }

    final userId = await SessionManager.getUserId();

    if (userId == null || userId.isEmpty) {
      _showMessage('Please login first');
      return;
    }

    try {
      final response = await _apiService.addRating(
        userId: userId,
        movieId: widget.movieId,
        rating: _selectedRating,
      );

      if (!mounted) return;

      if (response is Map &&
          response['status']?.toString().toLowerCase() ==
              'success') {
        _showMessage('Rating submitted');

        await _loadMovieDetails();
      } else {
        _showMessage(
          response is Map
              ? response['message']?.toString() ??
              'Unable to submit rating'
              : 'Unable to submit rating',
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Something went wrong');
      }
    }
  }

  // ============================================================
  // SUBMIT REVIEW
  // ============================================================

  Future<void> _submitReview() async {
    final reviewText = _reviewController.text.trim();

    if (reviewText.isEmpty) {
      _showMessage('Please write a review');
      return;
    }

    final userId = await SessionManager.getUserId();

    if (userId == null || userId.isEmpty) {
      _showMessage('Please login first');
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      final response = await _apiService.addReview(
        userId: userId,
        movieId: widget.movieId,
        review: reviewText,
      );

      if (!mounted) return;

      if (response is Map &&
          response['status']?.toString().toLowerCase() ==
              'success') {
        _reviewController.clear();

        _showMessage('Review added successfully');

        await _loadMovieDetails();
      } else {
        _showMessage(
          response is Map
              ? response['message']?.toString() ??
              'Unable to submit review'
              : 'Unable to submit review',
        );
      }
    } catch (e) {
      debugPrint('Submit review error: $e');

      if (mounted) {
        _showMessage('Something went wrong');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingReview = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF312A44),
      appBar: AppBar(
        backgroundColor: const Color(0xFF312A44),
        foregroundColor: const Color(0xFFF2F0EC),
        elevation: 0,
        title: const Text(
          'Movie Details',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD7C5D8),
        ),
      )
          : _movie == null
          ? const Center(
        child: Text(
          'Movie not found',
          style: TextStyle(
            color: Color(0xFFF2F0EC),
          ),
        ),
      )
          : _buildMovieDetails(),
    );
  }

  // ============================================================
  // MOVIE DETAILS
  // ============================================================

  Widget _buildMovieDetails() {
    final movie = _movie!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // POSTER
          // ======================================================

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                movie.moviePoster,
                height: 360,
                width: 240,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 360,
                    width: 240,
                    color: const Color(0xFF3D354F),
                    child: const Icon(
                      Icons.movie_outlined,
                      size: 70,
                      color: Color(0xFF88708E),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ======================================================
          // MOVIE NAME
          // ======================================================

          Text(
            movie.movieName,
            style: const TextStyle(
              color: Color(0xFFF2F0EC),
              fontSize: 27,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),

          const SizedBox(height: 10),

          // ======================================================
          // GENRE
          // ======================================================

          Text(
            movie.genre,
            style: const TextStyle(
              color: Color(0xFFD7C5D8),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          // ======================================================
          // RELEASE DATE
          // ======================================================

          Text(
            'Release Date: ${movie.releaseDate}',
            style: const TextStyle(
              color: Color(0xFFB7B4AE),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 15),

          // ======================================================
          // RATING
          // ======================================================

          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFD7C5D8),
              ),
              const SizedBox(width: 6),
              Text(
                movie.rating,
                style: const TextStyle(
                  color: Color(0xFFF2F0EC),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ======================================================
          // DESCRIPTION
          // ======================================================

          Text(
            movie.description,
            style: const TextStyle(
              color: Color(0xFFB7B4AE),
              fontSize: 14,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 25),

          // ======================================================
          // WATCHLIST + WATCHED
          // ======================================================

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                  _isWatchlisted ? null : _addToWatchlist,
                  icon: Icon(
                    _isWatchlisted
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                  label: Text(
                    _isWatchlisted
                        ? 'In Watchlist'
                        : 'Watchlist',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFD7C5D8),
                    foregroundColor:
                    const Color(0xFF312A44),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                  _isWatched ? null : _markAsWatched,
                  icon: Icon(
                    _isWatched
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                  ),
                  label: Text(
                    _isWatched
                        ? 'Watched'
                        : 'Mark Watched',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF3D354F),
                    foregroundColor:
                    const Color(0xFFF2F0EC),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // ======================================================
          // RATING SECTION
          // ======================================================

          const Text(
            'Rate this movie',
            style: TextStyle(
              color: Color(0xFFF2F0EC),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: List.generate(
              5,
                  (index) {
                final rating = index + 1;

                return IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedRating =
                          rating.toDouble();
                    });
                  },
                  icon: Icon(
                    rating <= _selectedRating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: const Color(0xFFD7C5D8),
                    size: 32,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: _submitRating,
            style: ElevatedButton.styleFrom(
              backgroundColor:
              const Color(0xFFD7C5D8),
              foregroundColor:
              const Color(0xFF312A44),
            ),
            child: const Text('Submit Rating'),
          ),

          const SizedBox(height: 30),

          // ======================================================
          // REVIEWS
          // ======================================================

          const Text(
            'Reviews',
            style: TextStyle(
              color: Color(0xFFF2F0EC),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),

          const SizedBox(height: 15),

          // ======================================================
          // WRITE REVIEW
          // ======================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3D354F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF88708E),
                width: 0.7,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Write a review',
                  style: TextStyle(
                    color: Color(0xFFF2F0EC),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: _reviewController,
                  maxLines: 4,
                  maxLength: 500,
                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                  ),
                  decoration: InputDecoration(
                    hintText:
                    'Share your thoughts about this movie...',
                    hintStyle: const TextStyle(
                      color: Color(0xFFB7B4AE),
                    ),
                    filled: true,
                    fillColor:
                    const Color(0xFF312A44),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF88708E),
                      ),
                    ),
                    enabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF88708E),
                      ),
                    ),
                    focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD7C5D8),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmittingReview
                        ? null
                        : _submitReview,
                    icon: _isSubmittingReview
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                        Color(0xFF312A44),
                      ),
                    )
                        : const Icon(
                      Icons.send_rounded,
                    ),
                    label: Text(
                      _isSubmittingReview
                          ? 'Submitting...'
                          : 'Submit Review',
                    ),
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFD7C5D8),
                      foregroundColor:
                      const Color(0xFF312A44),
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // EXISTING REVIEWS
          // ======================================================

          if (_reviews.isEmpty)
            const Text(
              'No reviews yet.',
              style: TextStyle(
                color: Color(0xFFB7B4AE),
              ),
            )
          else
            ..._reviews.map(
                  (review) => _buildReview(review),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // REVIEW CARD
  // ============================================================

  Widget _buildReview(ReviewModel review) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF3D354F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF88708E),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: Color(0xFFD7C5D8),
                size: 20,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'User ${review.userId}',
                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            review.review,
            style: const TextStyle(
              color: Color(0xFFB7B4AE),
              height: 1.5,
              fontSize: 14,
            ),
          ),

          if (review.createdAt.isNotEmpty) ...[
            const SizedBox(height: 8),

            Text(
              review.createdAt,
              style: const TextStyle(
                color: Color(0xFF88708E),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}