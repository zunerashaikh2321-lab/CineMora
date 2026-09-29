import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final bool showValue;

  const RatingWidget({
    super.key,
    required this.rating,
    this.size = 20,
    this.showValue = true,
  });

  @override
  Widget build(BuildContext context) {
    final double safeRating = rating.clamp(0.0, 5.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starNumber = index + 1;

          return Icon(
            safeRating >= starNumber
                ? Icons.star
                : safeRating >= starNumber - 0.5
                ? Icons.star_half
                : Icons.star_border,
            color: const Color(0xFFD6D4DF),
            size: size,
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 6),
          Text(
            safeRating.toStringAsFixed(1),
            style: TextStyle(
              color: const Color(0xFFD6D4DF),
              fontSize: size * 0.65,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}