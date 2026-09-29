class AppConstants {
  AppConstants._();

  // ============================================================
  // APP
  // ============================================================

  static const String appName = 'CineMora';
  static const String tagline = 'Discover. Watch. Belong.';

  // ============================================================
  // ROUTES
  // ============================================================

  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String otpRoute = '/otp';
  static const String homeRoute = '/home';
  static const String movieDetailsRoute = '/movie-details';
  static const String searchRoute = '/search';
  static const String categoriesRoute = '/categories';
  static const String watchlistRoute = '/watchlist';
  static const String watchedMoviesRoute = '/watched-movies';
  static const String profileRoute = '/profile';
  static const String editProfileRoute = '/edit-profile';
  static const String changePasswordRoute = '/change-password';
  static const String myReviewsRoute = '/my-reviews';
  static const String writeReviewRoute = '/write-review';

  // ============================================================
  // API ACTIONS
  // ============================================================

  static const String getMovies = 'getMovies';
  static const String getMovie = 'getMovie';
  static const String getCategories = 'getCategories';
  static const String getUser = 'getUser';
  static const String getReviews = 'getReviews';
  static const String getWatchlist = 'getWatchlist';
  static const String getWatchedMovies = 'getWatchedMovies';

  static const String signup = 'signup';
  static const String login = 'login';
  static const String forgotPassword = 'forgotPassword';
  static const String updateProfile = 'updateProfile';
  static const String changePassword = 'changePassword';

  static const String addWatchlist = 'addWatchlist';
  static const String removeWatchlist = 'removeWatchlist';

  static const String markWatched = 'markWatched';
  static const String removeWatched = 'removeWatched';

  static const String addReview = 'addReview';
  static const String addRating = 'addRating';

  // ============================================================
  // MOVIE
  // ============================================================

  static const double minimumRating = 1.0;
  static const double maximumRating = 5.0;

  // ============================================================
  // ASSETS
  // ============================================================

  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String loggedInKey = 'is_logged_in';

  // ============================================================
  // COMMON MESSAGES
  // ============================================================

  static const String somethingWentWrong =
      'Something went wrong. Please try again.';

  static const String networkError =
      'Please check your internet connection.';

  static const String requiredField =
      'This field is required.';
}