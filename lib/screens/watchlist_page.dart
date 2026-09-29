import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../services/api_service.dart';
import '../utils/session_manager.dart';
import 'movie_details_page.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final ApiService _apiService = ApiService();

  List<MovieModel> _watchlistMovies = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  // ============================================================
  // LOAD WATCHLIST
  // ============================================================

  Future<void> _loadWatchlist() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await SessionManager.getUserId();

      if (userId == null || userId.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _errorMessage = 'Please login to view your watchlist.';
        });

        return;
      }

      final response = await _apiService.getWatchlist(userId);

      if (!mounted) return;

      if (response is Map &&
          response['status']?.toString().toLowerCase() == 'success') {
        final data = response['data'];

        if (data is List) {
          final movies = data
              .whereType<Map>()
              .map(
                (item) => MovieModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
              .toList();

          setState(() {
            _watchlistMovies = movies;
            _isLoading = false;
          });
        } else {
          setState(() {
            _watchlistMovies = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response is Map
              ? response['message']?.toString() ??
              'Unable to load watchlist.'
              : 'Unable to load watchlist.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load watchlist.';
      });

      debugPrint('Watchlist error: $e');
    }
  }

  // ============================================================
  // OPEN MOVIE DETAILS
  // ============================================================

  Future<void> _openMovie(MovieModel movie) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailsPage(
          movieId: movie.movieId,
        ),
      ),
    );

    if (!mounted) return;

    await _loadWatchlist();
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
          'My Watchlist',
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

    if (_watchlistMovies.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _loadWatchlist,
      color: const Color(0xFF312A44),
      backgroundColor: const Color(0xFFD7C5D8),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          15,
          20,
          30,
        ),
        itemCount: _watchlistMovies.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 18,
          childAspectRatio: 0.68,
        ),
        itemBuilder: (context, index) {
          final movie = _watchlistMovies[index];

          return _buildMovieCard(movie);
        },
      ),
    );
  }

  // ============================================================
  // WATCHLIST MOVIE CARD
  // ============================================================

  Widget _buildMovieCard(MovieModel movie) {
    return GestureDetector(
      onTap: () => _openMovie(movie),
      child: Container(
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
              Icons.bookmark_border_rounded,
              size: 70,
              color: Color(0xFFD7C5D8),
            ),
            const SizedBox(height: 18),
            const Text(
              'Your watchlist is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFF2F0EC),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Movies you add to your watchlist will appear here.',
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
              onPressed: _loadWatchlist,
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