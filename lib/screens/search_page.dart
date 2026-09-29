import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import 'movie_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController =
  TextEditingController();

  List<MovieModel> _allMovies = [];
  List<MovieModel> _searchResults = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD MOVIES FROM API
  // ============================================================

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getMovies();

      if (!mounted) return;

      if (response is Map &&
          response['status']?.toString().toLowerCase() ==
              'success') {
        final data = response['data'];

        if (data is List) {
          _allMovies = data
              .map(
                (item) => MovieModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
              .toList();

          _searchResults = List.from(_allMovies);
        }
      } else {
        _errorMessage = response is Map
            ? response['message']?.toString() ??
            'Unable to load movies.'
            : 'Unable to load movies.';
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load movies.';
      });

      debugPrint('Search movies error: $e');
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _searchMovies(String query) {
    final searchText = query.trim().toLowerCase();

    if (searchText.isEmpty) {
      setState(() {
        _searchResults = List.from(_allMovies);
      });
      return;
    }

    setState(() {
      _searchResults = _allMovies.where((movie) {
        final movieName = movie.movieName.toLowerCase();
        final genre = movie.genre.toLowerCase();
        final description = movie.description.toLowerCase();

        return movieName.contains(searchText) ||
            genre.contains(searchText) ||
            description.contains(searchText);
      }).toList();
    });
  }

  // ============================================================
  // OPEN MOVIE DETAILS
  // ============================================================

  void _openMovie(MovieModel movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailsPage(
          movieId: movie.movieId,
        ),
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
          'Search Movies',
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

    return RefreshIndicator(
      onRefresh: _loadMovies,
      color: const Color(0xFF312A44),
      backgroundColor: const Color(0xFFD7C5D8),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                20,
              ),
              child: _buildSearchField(),
            ),
          ),
          _buildResults(),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH FIELD
  // ============================================================

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _searchMovies,
      style: const TextStyle(
        color: Color(0xFFF2F0EC),
      ),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by movie, genre...',
        hintStyle: const TextStyle(
          color: Color(0xFFB7B4AE),
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFFD7C5D8),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          onPressed: () {
            _searchController.clear();
            _searchMovies('');
          },
          icon: const Icon(
            Icons.close_rounded,
            color: Color(0xFFB7B4AE),
          ),
        )
            : null,
        filled: true,
        fillColor: const Color(0xFF3D354F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFD7C5D8),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RESULTS
  // ============================================================

  Widget _buildResults() {
    if (_searchResults.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 65,
                  color: Color(0xFFD7C5D8),
                ),
                const SizedBox(height: 15),
                Text(
                  _searchController.text.trim().isEmpty
                      ? 'No movies available.'
                      : 'No movies found.',
                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        30,
      ),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final movie = _searchResults[index];

            return MovieCard(
              movie: movie,
              onTap: () => _openMovie(movie),
            );
          },
          childCount: _searchResults.length,
        ),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 18,
          childAspectRatio: 0.58,
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
              onPressed: _loadMovies,
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