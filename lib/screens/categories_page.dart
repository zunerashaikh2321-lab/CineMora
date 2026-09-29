import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import '../widgets/movie_card.dart';

import 'movie_details_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final ApiService _apiService = ApiService();

  List<CategoryModel> _categories = [];
  List<MovieModel> _allMovies = [];
  List<MovieModel> _categoryMovies = [];

  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedCategoryId;
  String _selectedCategoryName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // LOAD CATEGORIES + MOVIES
  // ============================================================

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // ========================================================
      // GET CATEGORIES
      // ========================================================

      final categoriesResponse =
      await _apiService.getCategories();

      if (!mounted) return;

      List<CategoryModel> loadedCategories = [];

      if (categoriesResponse is Map &&
          categoriesResponse['status']
              ?.toString()
              .toLowerCase() ==
              'success') {
        final data = categoriesResponse['data'];

        if (data is List) {
          for (final item in data) {
            try {
              if (item is Map) {
                final category = CategoryModel.fromJson(
                  Map<String, dynamic>.from(item),
                );

                if (category.status.toLowerCase() != 'inactive') {
                  loadedCategories.add(category);
                }
              }
            } catch (e) {
              debugPrint(
                'Category parsing error = $e',
              );
            }
          }
        }
      } else {
        throw Exception(
          categoriesResponse is Map
              ? categoriesResponse['message']?.toString()
              : 'Unable to load categories',
        );
      }

      // ========================================================
      // GET MOVIES
      // ========================================================

      final moviesResponse =
      await _apiService.getMovies();

      if (!mounted) return;

      List<MovieModel> loadedMovies = [];

      if (moviesResponse is Map &&
          moviesResponse['status']
              ?.toString()
              .toLowerCase() ==
              'success') {
        final data = moviesResponse['data'];

        if (data is List) {
          for (final item in data) {
            try {
              if (item is Map) {
                final movie = MovieModel.fromJson(
                  Map<String, dynamic>.from(item),
                );

                loadedMovies.add(movie);
              }
            } catch (e) {
              debugPrint(
                'Movie parsing error = $e',
              );
            }
          }
        }
      } else {
        throw Exception(
          moviesResponse is Map
              ? moviesResponse['message']?.toString()
              : 'Unable to load movies',
        );
      }

      // ========================================================
      // UPDATE UI
      // ========================================================

      if (!mounted) return;

      setState(() {
        _categories = loadedCategories;
        _allMovies = loadedMovies;
        _isLoading = false;

        // Reset selected category after refresh
        _selectedCategoryId = null;
        _selectedCategoryName = '';
        _categoryMovies = [];
      });

      debugPrint(
        'TOTAL CATEGORIES = ${_categories.length}',
      );

      debugPrint(
        'TOTAL MOVIES = ${_allMovies.length}',
      );
    } catch (e) {
      debugPrint(
        'Categories page error = $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Unable to load categories and movies.';
      });
    }
  }

  // ============================================================
  // SELECT CATEGORY
  // ============================================================

  void _selectCategory(CategoryModel category) {
    final selectedCategoryName =
    category.categoryName.trim().toLowerCase();

    final filteredMovies = _allMovies.where((movie) {
      final movieGenre =
      movie.genre.trim().toLowerCase();

      return movieGenre == selectedCategoryName;
    }).toList();

    if (!mounted) return;

    setState(() {
      _selectedCategoryId = category.categoryId;
      _selectedCategoryName = category.categoryName;
      _categoryMovies = filteredMovies;
    });

    debugPrint(
      'SELECTED CATEGORY = ${category.categoryName}',
    );

    debugPrint(
      'CATEGORY MOVIES = ${filteredMovies.length}',
    );
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
          'Categories',
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

    if (_categories.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _loadData,

      color: const Color(0xFF312A44),
      backgroundColor: const Color(0xFFD7C5D8),

      child: SingleChildScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          20,
          15,
          20,
          30,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ==================================================
            // CATEGORY TITLE
            // ==================================================

            const Text(
              'Browse Categories',
              style: TextStyle(
                color: Color(0xFFF2F0EC),
                fontSize: 21,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // CATEGORY CARDS
            // ==================================================

            Wrap(
              spacing: 10,
              runSpacing: 10,

              children: _categories.map((category) {
                final isSelected =
                    _selectedCategoryId ==
                        category.categoryId;

                return GestureDetector(
                  onTap: () {
                    _selectCategory(category);
                  },

                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),

                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD7C5D8)
                          : const Color(0xFF3D354F),

                      borderRadius:
                      BorderRadius.circular(12),

                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD7C5D8)
                            : const Color(0xFF88708E),

                        width: 0.8,
                      ),
                    ),

                    child: Text(
                      category.categoryName,

                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF312A44)
                            : const Color(0xFFF2F0EC),

                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // SELECTED CATEGORY MOVIES
            // ==================================================

            if (_selectedCategoryId != null)
              _buildCategoryMovies(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY MOVIES
  // ============================================================

  Widget _buildCategoryMovies() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$_selectedCategoryName Movies',

                style: const TextStyle(
                  color: Color(0xFFF2F0EC),
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                ),
              ),
            ),

            Text(
              '${_categoryMovies.length}',

              style: const TextStyle(
                color: Color(0xFFB7B4AE),
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        if (_categoryMovies.isEmpty)
          _buildNoMovies()
        else
          GridView.builder(
            shrinkWrap: true,

            physics:
            const NeverScrollableScrollPhysics(),

            itemCount:
            _categoryMovies.length,

            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 18,
              childAspectRatio: 0.58,
            ),

            itemBuilder: (context, index) {
              final movie =
              _categoryMovies[index];

              return MovieCard(
                movie: movie,
                onTap: () =>
                    _openMovie(movie),
              );
            },
          ),
      ],
    );
  }

  // ============================================================
  // NO MOVIES
  // ============================================================

  Widget _buildNoMovies() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        vertical: 35,
        horizontal: 20,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFF3D354F),
        borderRadius:
        BorderRadius.circular(16),
      ),

      child: const Column(
        children: [
          Icon(
            Icons.movie_outlined,
            size: 50,
            color: Color(0xFFD7C5D8),
          ),

          SizedBox(height: 12),

          Text(
            'No movies found in this category.',
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Color(0xFFF2F0EC),
              fontSize: 15,
            ),
          ),
        ],
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
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.category_outlined,
              size: 65,
              color: Color(0xFFD7C5D8),
            ),

            const SizedBox(height: 18),

            const Text(
              'No categories available',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Color(0xFFF2F0EC),
                fontSize: 19,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
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
          mainAxisAlignment:
          MainAxisAlignment.center,

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
              onPressed: _loadData,

              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFD7C5D8),

                foregroundColor:
                const Color(0xFF312A44),
              ),

              child:
              const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}