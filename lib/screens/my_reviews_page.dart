import 'package:flutter/material.dart';

import '../models/review_model.dart';
import '../services/api_service.dart';

class MyReviewsPage extends StatefulWidget {
  final String userId;

  const MyReviewsPage({
    super.key,
    required this.userId,
  });

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  final ApiService _apiService = ApiService();

  List<ReviewModel> _reviews = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  // ============================================================
  // LOAD REVIEWS
  // ============================================================

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      /*
       * getReviews() requires movieId, but this page needs
       * reviews belonging to the current user.
       *
       * Therefore the API response should support filtering
       * by user_id.
       */

      final response = await _apiService.getMyReviews(
        widget.userId,
      );

      if (!mounted) return;

      if (response is Map &&
          response['status']?.toString().toLowerCase() ==
              'success') {
        final data = response['data'];

        if (data is List) {
          _reviews = data
              .map(
                (item) => ReviewModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
              .toList();
        }
      } else {
        _errorMessage = response is Map
            ? response['message']?.toString() ??
            'Unable to load reviews.'
            : 'Unable to load reviews.';
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load reviews.';
      });

      debugPrint('My reviews error: $e');
    }
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
          'My Reviews',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD7C5D8),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_reviews.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      color: const Color(0xFF312A44),
      backgroundColor: const Color(0xFFD7C5D8),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          15,
          20,
          30,
        ),
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          return _buildReviewCard(
            _reviews[index],
          );
        },
      ),
    );
  }

  // ============================================================
  // REVIEW CARD
  // ============================================================

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF3D354F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.rate_review_outlined,
                color: Color(0xFFD7C5D8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _movieTitle(review),
                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            _reviewText(review),
            style: const TextStyle(
              color: Color(0xFFB7B4AE),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            _reviewDate(review),
            style: const TextStyle(
              color: Color(0xFF88708E),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REVIEW DATA HELPERS
  // ============================================================

  String _movieTitle(ReviewModel review) {
    return 'Movie Review';
  }
  String _reviewText(ReviewModel review) {
    return review.review;
  }

  String _reviewDate(ReviewModel review) {
    try {
      return review.createdAt;
    } catch (_) {
      return '';
    }
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rate_review_outlined,
              size: 65,
              color: Color(0xFFD7C5D8),
            ),
            const SizedBox(height: 18),
            const Text(
              'No reviews yet',
              style: TextStyle(
                color: Color(0xFFF2F0EC),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your movie reviews will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFB7B4AE),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: Color(0xFFD7C5D8),
            ),
            const SizedBox(height: 18),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFF2F0EC),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadReviews,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD7C5D8),
                foregroundColor: const Color(0xFF312A44),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}