import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../theme/app_colors.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.plumBlossom.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.duskyLilac.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.duskyLilac,
                child: const Icon(
                  Icons.person,
                  color: AppColors.silverWisteria,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.userId.isEmpty
                      ? 'User'
                      : review.userId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.silverWisteria,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            review.review,
            style: const TextStyle(
              color: AppColors.silverWisteria,
              fontSize: 14,
              height: 1.5,
              fontFamily: 'Georgia',
            ),
          ),

          const SizedBox(height: 8),

          Text(
            review.createdAt,
            style: const TextStyle(
              color: AppColors.duskyLilac,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}