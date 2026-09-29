import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/category_card.dart';
import '../widgets/bottom_nav_bar.dart';

import 'watched_movies_page.dart';
import 'categories_page.dart';
import 'movie_details_page.dart';
import 'search_page.dart';
import 'watchlist_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();

  List<MovieModel> _movies = [];
  List<CategoryModel> _categories = [];

  bool _isLoading = true;
  String? _errorMessage;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  // ============================================================
  // COMMON MESSAGE / SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF3D354F),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Color(0xFFF2F0EC),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
  }

  // ============================================================
  // LOAD HOME DATA FROM API
  // ============================================================

  Future<void> _loadHomeData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // ========================================================
      // GET MOVIES
      // ========================================================

      final moviesResponse = await _apiService.getMovies();

      debugPrint('==========================================');
      debugPrint('HOME MOVIES RESPONSE');
      debugPrint('$moviesResponse');
      debugPrint('==========================================');

      if (!mounted) return;

      List<MovieModel> loadedMovies = [];

      if (moviesResponse is Map) {
        final status =
        moviesResponse['status']?.toString().toLowerCase();

        if (status == 'success') {
          final movieData = moviesResponse['data'];

          if (movieData is List) {
            for (final item in movieData) {
              try {
                if (item is Map) {
                  final movie = MovieModel.fromJson(
                    Map<String, dynamic>.from(item),
                  );

                  loadedMovies.add(movie);
                }
              } catch (e) {
                debugPrint('Movie parsing error: $e');
              }
            }
          }
        } else {
          debugPrint(
            'Movies API error: ${moviesResponse['message']}',
          );
        }
      }

      // ========================================================
      // GET CATEGORIES
      // ========================================================

      final categoriesResponse =
      await _apiService.getCategories();

      debugPrint('==========================================');
      debugPrint('HOME CATEGORIES RESPONSE');
      debugPrint('$categoriesResponse');
      debugPrint('==========================================');

      if (!mounted) return;

      List<CategoryModel> loadedCategories = [];

      if (categoriesResponse is Map) {
        final status =
        categoriesResponse['status']?.toString().toLowerCase();

        if (status == 'success') {
          final categoryData = categoriesResponse['data'];

          if (categoryData is List) {
            for (final item in categoryData) {
              try {
                if (item is Map) {
                  final category =
                  CategoryModel.fromJson(
                    Map<String, dynamic>.from(item),
                  );

                  loadedCategories.add(category);
                }
              } catch (e) {
                debugPrint(
                  'Category parsing error: $e',
                );
              }
            }
          }
        } else {
          debugPrint(
            'Categories API error: '
                '${categoriesResponse['message']}',
          );
        }
      }

      // ========================================================
      // UPDATE UI
      // ========================================================

      if (!mounted) return;

      setState(() {
        _movies = loadedMovies;
        _categories = loadedCategories;
        _isLoading = false;
      });

      debugPrint(
        'TOTAL MOVIES LOADED = ${_movies.length}',
      );

      debugPrint(
        'TOTAL CATEGORIES LOADED = '
            '${_categories.length}',
      );
    } catch (e) {
      debugPrint('HOME PAGE ERROR = $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Unable to load movies. Please try again.';
      });
    }
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // ----------------------------------------------------------
    // HOME
    // ----------------------------------------------------------

    if (index == 0) {
      return;
    }

    // ----------------------------------------------------------
    // SEARCH
    // ----------------------------------------------------------

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SearchPage(),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // WATCHLIST
    // ----------------------------------------------------------

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WatchlistPage(),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // WATCHED MOVIES
    // ----------------------------------------------------------

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WatchedMoviesPage(),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // PROFILE
    // ----------------------------------------------------------

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        ),
      );
      return;
    }
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
  // OPEN SEARCH
  // ============================================================

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchPage(),
      ),
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    await _loadHomeData();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF312A44),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: const Color(0xFF312A44),
          backgroundColor: const Color(0xFFD7C5D8),
          child: _buildBody(),
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
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
      return _buildErrorState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        25,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 22),

          _buildSearchBar(),

          const SizedBox(height: 28),

          // ====================================================
          // CATEGORIES
          // ====================================================

          _buildSectionTitle(
            title: 'Categories',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoriesPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          _buildCategories(),

          const SizedBox(height: 30),

          // ====================================================
          // MOVIES
          // ====================================================

          _buildSectionTitle(
            title: 'Movies',
          ),

          const SizedBox(height: 14),

          _buildMovies(),

          const SizedBox(height: 30),

          // ====================================================
          // RECOMMENDED
          // ====================================================

          _buildSectionTitle(
            title: 'Recommended for You',
          ),

          const SizedBox(height: 14),

          _buildSuggestedMovies(),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Welcome to',
                style: TextStyle(
                  color: Color(0xFFB7B4AE),
                  fontSize: 14,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'CineMora',
                style: TextStyle(
                  color: Color(0xFFF2F0EC),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                ),
              ),
            ],
          ),
        ),

        Container(
          height: 44,
          width: 44,

          decoration: BoxDecoration(
            color: const Color(0xFF3D354F),
            borderRadius: BorderRadius.circular(14),
          ),

          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },

            icon: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFFD7C5D8),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _openSearch,

      child: Container(
        height: 52,

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),

        decoration: BoxDecoration(
          color: const Color(0xFF3D354F),
          borderRadius: BorderRadius.circular(16),
        ),

        child: const Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: Color(0xFFB7B4AE),
            ),

            SizedBox(width: 12),

            Text(
              'Search movies, genres...',
              style: TextStyle(
                color: Color(0xFF88708E),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required String title,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF2F0EC),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Georgia',
            ),
          ),
        ),

        if (onTap != null)
          GestureDetector(
            onTap: onTap,

            child: const Text(
              'See all',
              style: TextStyle(
                color: Color(0xFFD7C5D8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    if (_categories.isEmpty) {
      return const Text(
        'No categories available.',
        style: TextStyle(
          color: Color(0xFFB7B4AE),
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];

          return CategoryCard(
            category: category,

            // ==========================================
            // CATEGORY CLICK
            // ==========================================
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoriesPage(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // MOVIES
  // ============================================================

  Widget _buildMovies() {
    if (_movies.isEmpty) {
      return const Text(
        'No movies available.',
        style: TextStyle(
          color: Color(0xFFB7B4AE),
        ),
      );
    }

    return SizedBox(
      height: 285,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemCount: _movies.length,

        separatorBuilder: (_, __) =>
        const SizedBox(width: 14),

        itemBuilder: (context, index) {
          final movie = _movies[index];

          return MovieCard(
            movie: movie,
            onTap: () => _openMovie(movie),
          );
        },
      ),
    );
  }

  // ============================================================
  // RECOMMENDED MOVIES
  // ============================================================

  Widget _buildSuggestedMovies() {
    final suggestedMovies = _movies.where((movie) {
      final value =
      movie.isSuggested.toLowerCase().trim();

      return value == 'true' ||
          value == 'yes' ||
          value == '1';
    }).toList();

    if (suggestedMovies.isEmpty) {
      return const Text(
        'No recommendations available.',
        style: TextStyle(
          color: Color(0xFFB7B4AE),
        ),
      );
    }

    return SizedBox(
      height: 285,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemCount: suggestedMovies.length,

        separatorBuilder: (_, __) =>
        const SizedBox(width: 14),

        itemBuilder: (context, index) {
          final movie = suggestedMovies[index];

          return MovieCard(
            movie: movie,
            onTap: () => _openMovie(movie),
          );
        },
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 65,
              color: Color(0xFFD7C5D8),
            ),

            const SizedBox(height: 20),

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
              onPressed: _loadHomeData,

              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFD7C5D8),
                foregroundColor:
                const Color(0xFF312A44),
              ),

              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}