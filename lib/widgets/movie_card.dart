import 'package:flutter/material.dart';
import '../models/movie_model.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 145,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF3D354F),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: movie.moviePoster.isNotEmpty
                  ? Image.network(
                movie.moviePoster,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _posterPlaceholder();
                },
              )
                  : _posterPlaceholder(),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 3),
              child: Text(
                movie.movieName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFF2F0EC),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFC8A96B),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    movie.rating.isEmpty ? '0.0' : movie.rating,
                    style: const TextStyle(
                      color: Color(0xFFB7B4AE),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF312A44),
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          color: Color(0xFFB7B4AE),
          size: 42,
        ),
      ),
    );
  }
}