import 'dart:convert';

import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl =
      'https://script.google.com/macros/s/AKfycbyzOK8d1i2-W_F0CE9_JzIJ5M5Dvfs3v7GaPKlM2fj49jfoFP-myH_3l3zNhMl9_3rC/exec';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),

        // IMPORTANT:
        // Google Apps Script ContentService returns 302.
        // We handle the redirect manually.
        followRedirects: false,

        validateStatus: (status) {
          return status != null && status >= 200 && status < 400;
        },

        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  // ============================================================
  // GET REQUEST
  // ============================================================

  Future<dynamic> getRequest(
      String action, {
        Map<String, dynamic>? params,
      }) async {
    try {
      final queryParameters = <String, dynamic>{
        'action': action,
        ...?params,
      };

      final response = await _dio.get(
        '',
        queryParameters: queryParameters,
        options: Options(
          followRedirects: false,
        ),
      );

      final finalResponse = await _handleRedirect(response);

      debugApi(
        action: action,
        response: finalResponse.data,
      );

      return _parseResponse(finalResponse.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  // ============================================================
  // POST REQUEST
  // ============================================================

  Future<dynamic> postRequest(
      String action, {
        Map<String, dynamic>? data,
      }) async {
    try {
      final requestData = <String, dynamic>{
        'action': action,
        ...?data,
      };

      print('');
      print('==============================================');
      print('REQUEST ACTION: $action');
      print('REQUEST METHOD: POST');
      print('REQUEST DATA: $requestData');
      print('REQUEST URL: $baseUrl');
      print('==============================================');

      final response = await _dio.post(
        '',
        data: requestData,

        // IMPORTANT:
        // Do NOT let Dio automatically follow Google's 302.
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status != null && status >= 200 && status < 400;
          },
        ),
      );

      final finalResponse = await _handleRedirect(response);

      debugApi(
        action: action,
        response: finalResponse.data,
      );

      return _parseResponse(finalResponse.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  // ============================================================
  // HANDLE GOOGLE APPS SCRIPT REDIRECT
  // ============================================================

  Future<Response> _handleRedirect(Response response) async {
    final statusCode = response.statusCode;

    print('');
    print('========== REDIRECT CHECK ==========');
    print('STATUS CODE: $statusCode');
    print('STATUS MESSAGE: ${response.statusMessage}');
    print('RESPONSE DATA: ${response.data}');
    print('HEADERS: ${response.headers}');
    print('=====================================');

    // ----------------------------------------------------------
    // NORMAL RESPONSE
    // ----------------------------------------------------------

    if (statusCode != 302 &&
        statusCode != 301 &&
        statusCode != 303 &&
        statusCode != 307 &&
        statusCode != 308) {
      return response;
    }

    // ----------------------------------------------------------
    // GET REDIRECT LOCATION
    // ----------------------------------------------------------

    String? redirectUrl =
    response.headers.value('location');

    if (redirectUrl == null ||
        redirectUrl.trim().isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Redirect received but Location header is missing',
      );
    }

    redirectUrl = redirectUrl.trim();

    print('');
    print('========== GOOGLE REDIRECT ==========');
    print('REDIRECT URL: $redirectUrl');
    print('=====================================');

    // ----------------------------------------------------------
    // FOLLOW GOOGLE'S ONE-TIME URL
    // ----------------------------------------------------------

    final redirectedResponse = await _dio.get(
      redirectUrl,
      options: Options(
        followRedirects: true,
        maxRedirects: 10,

        validateStatus: (status) {
          return status != null && status >= 200 && status < 400;
        },
      ),
    );

    print('');
    print('========== FINAL RESPONSE ==========');
    print('STATUS CODE: ${redirectedResponse.statusCode}');
    print('STATUS MESSAGE: ${redirectedResponse.statusMessage}');
    print('DATA: ${redirectedResponse.data}');
    print('====================================');

    return redirectedResponse;
  }

  // ============================================================
  // RESPONSE PARSER
  // ============================================================

  dynamic _parseResponse(dynamic data) {
    // ----------------------------------------------------------
    // MAP
    // ----------------------------------------------------------

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    // ----------------------------------------------------------
    // STRING
    // ----------------------------------------------------------

    if (data is String) {
      final text = data.trim();

      if (text.isEmpty) {
        return {
          'status': 'error',
          'message': 'Empty server response',
        };
      }

      try {
        final decoded = jsonDecode(text);

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }

        if (decoded is List) {
          return {
            'status': 'success',
            'data': decoded,
          };
        }

        return {
          'status': 'error',
          'message': 'Invalid JSON response',
        };
      } catch (_) {
        return {
          'status': 'error',
          'message': text,
        };
      }
    }

    // ----------------------------------------------------------
    // LIST
    // ----------------------------------------------------------

    if (data is List) {
      return {
        'status': 'success',
        'data': data,
      };
    }

    return {
      'status': 'error',
      'message': 'Invalid server response',
    };
  }

  // ============================================================
  // DEBUG
  // ============================================================

  void debugApi({
    required String action,
    required dynamic response,
  }) {
    print('');
    print('==============================================');
    print('API ACTION: $action');
    print('API RESPONSE TYPE: ${response.runtimeType}');
    print('API RESPONSE: $response');
    print('==============================================');
    print('');
  }

  // ============================================================
  // MOVIES
  // ============================================================

  Future<dynamic> getMovies() {
    return getRequest('getMovies');
  }

  Future<dynamic> getMovie(String movieId) {
    return getRequest(
      'getMovie',
      params: {
        'movie_id': movieId,
      },
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Future<dynamic> getCategories() {
    return getRequest('getCategories');
  }

  // ============================================================
  // USERS
  // ============================================================

  Future<dynamic> getUser(String userId) {
    return getRequest(
      'getUser',
      params: {
        'user_id': userId,
      },
    );
  }

  Future<dynamic> signup({
    required String name,
    required String birthdate,
    required String gender,
    required String email,
    required String password,
    required String phoneNumber,
    String termsAccepted = 'true',
    String profileImage = '',
  }) {
    return postRequest(
      'signup',
      data: {
        'name': name,
        'birthdate': birthdate,
        'gender': gender,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'terms_accepted': termsAccepted,
        'profile_image': profileImage,
      },
    );
  }

  Future<dynamic> login({
    required String email,
    required String password,
  }) {
    return getRequest(
      'login',
      params: {
        'email': email,
        'password': password,
      },
    );
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<dynamic> forgotPassword({
    required String email,
  }) {
    return postRequest(
      'forgotPassword',
      data: {
        'email': email,
      },
    );
  }

  Future<dynamic> verifyOtp({
    required String email,
    required String otp,
  }) {
    return postRequest(
      'verifyOtp',
      data: {
        'email': email,
        'otp': otp,
      },
    );
  }

  Future<dynamic> resetPassword({
    required String userId,
    required String otp,
    required String newPassword,
  }) {
    return postRequest(
      'resetPassword',
      data: {
        'user_id': userId,
        'otp': otp,
        'new_password': newPassword,
      },
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Future<dynamic> updateProfile({
    required String userId,
    String? name,
    String? birthdate,
    String? gender,
    String? email,
    String? phoneNumber,
    String? profileImage,
  }) {
    final data = <String, dynamic>{
      'user_id': userId,
    };

    if (name != null) {
      data['name'] = name;
    }

    if (birthdate != null) {
      data['birthdate'] = birthdate;
    }

    if (gender != null) {
      data['gender'] = gender;
    }

    if (email != null) {
      data['email'] = email;
    }

    if (phoneNumber != null) {
      data['phone_number'] = phoneNumber;
    }

    if (profileImage != null) {
      data['profile_image'] = profileImage;
    }

    return postRequest(
      'updateProfile',
      data: data,
    );
  }

  Future<dynamic> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) {
    return postRequest(
      'changePassword',
      data: {
        'user_id': userId,
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }

  // ============================================================
  // WATCHLIST
  // ============================================================

  Future<dynamic> getWatchlist(String userId) {
    return getRequest(
      'getWatchlist',
      params: {
        'user_id': userId,
      },
    );
  }

  Future<dynamic> addWatchlist({
    required String userId,
    required String movieId,
  }) {
    return postRequest(
      'addWatchlist',
      data: {
        'user_id': userId,
        'movie_id': movieId,
      },
    );
  }

  Future<dynamic> removeWatchlist({
    required String watchlistId,
  }) {
    return postRequest(
      'removeWatchlist',
      data: {
        'watchlist_id': watchlistId,
      },
    );
  }

  // ============================================================
  // WATCHED MOVIES
  // ============================================================

  Future<dynamic> getWatchedMovies(String userId) {
    return getRequest(
      'getWatchedMovies',
      params: {
        'user_id': userId,
      },
    );
  }

  Future<dynamic> markWatched({
    required String userId,
    required String movieId,
  }) {
    return postRequest(
      'markWatched',
      data: {
        'user_id': userId,
        'movie_id': movieId,
      },
    );
  }

  Future<dynamic> removeWatched({
    required String watchedId,
  }) {
    return postRequest(
      'removeWatched',
      data: {
        'watched_id': watchedId,
      },
    );
  }

  // ============================================================
  // REVIEWS
  // ============================================================

  Future<dynamic> getReviews(String movieId) {
    return getRequest(
      'getReviews',
      params: {
        'movie_id': movieId,
      },
    );
  }

  Future<dynamic> getMyReviews(String userId) {
    return getRequest(
      'getMyReviews',
      params: {
        'user_id': userId,
      },
    );
  }

  Future<dynamic> addReview({
    required String userId,
    required String movieId,
    required String review,
  }) {
    return postRequest(
      'addReview',
      data: {
        'user_id': userId,
        'movie_id': movieId,
        'review': review,
      },
    );
  }

  // ============================================================
  // RATINGS
  // ============================================================

  Future<dynamic> addRating({
    required String userId,
    required String movieId,
    required dynamic rating,
  }) {
    return postRequest(
      'addRating',
      data: {
        'user_id': userId,
        'movie_id': movieId,
        'rating': rating,
      },
    );
  }

  // ============================================================
  // ERROR HANDLER
  // ============================================================

  Map<String, dynamic> _handleDioError(
      DioException error,
      ) {
    print('');
    print('========== DIO ERROR ==========');
    print('TYPE: ${error.type}');
    print('MESSAGE: ${error.message}');
    print('ERROR: ${error.error}');
    print('STATUS CODE: ${error.response?.statusCode}');
    print('STATUS MESSAGE: ${error.response?.statusMessage}');
    print('RESPONSE DATA: ${error.response?.data}');
    print('REQUEST URL: ${error.requestOptions.uri}');
    print('REQUEST METHOD: ${error.requestOptions.method}');
    print('================================');

    final responseData = error.response?.data;

    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    if (responseData is String &&
        responseData.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(responseData);

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    return {
      'status': 'error',
      'message': error.message?.isNotEmpty == true
          ? error.message
          : 'Dio error: ${error.type}',
    };
  }
}