import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/session_manager.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';

class WriteReviewPage extends StatefulWidget {
  final String movieId;
  final String movieTitle;

  const WriteReviewPage({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final _controller = TextEditingController();
  final _api = ApiService();

  bool _loading = false;

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      _message('Please write a review.');
      return;
    }

    final userId = await SessionManager.getUserId();

    if (userId == null || userId.isEmpty) {
      _message('Please login first.');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final response = await _api.addReview(
        userId: userId,
        movieId: widget.movieId,
        review: text,
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      if (response is Map &&
          response['status']?.toString().toLowerCase() == 'success') {
        _message('Review submitted successfully.');

        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        final message = response is Map
            ? response['message']?.toString() ??
            'Unable to submit review.'
            : 'Unable to submit review.';

        _message(message);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _message('Something went wrong. Please try again.');
      debugPrint('Write review error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightOrchid,
      appBar: AppBar(
        title: const Text('Write Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.movieTitle,
              style: const TextStyle(
                color: AppColors.cream,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            TextField(
              controller: _controller,
              maxLines: 7,
              maxLength: 500,
              enabled: !_loading,
              style: const TextStyle(
                color: AppColors.cream,
              ),
              decoration: const InputDecoration(
                hintText: 'Write your review...',
                hintStyle: TextStyle(
                  color: AppColors.duskyLilac,
                ),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: CustomButton(
                text: _loading ? 'Submitting...' : 'Submit Review',
                onPressed: _loading ? () {} : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}