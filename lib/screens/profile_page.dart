import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/session_manager.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';
import 'my_reviews_page.dart';
import 'watchlist_page.dart';
import 'watched_movies_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();

  String? _userId;

  String _name = '';
  String _birthdate = '';
  String _gender = '';
  String _email = '';
  String _phoneNumber = '';
  String _profileImage = '';

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
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
          _errorMessage = 'Please login to view your profile.';
        });

        return;
      }

      _userId = userId;

      final response = await _apiService.getUser(userId);

      if (!mounted) return;

      if (response is Map &&
          response['status']?.toString().toLowerCase() ==
              'success') {
        dynamic data = response['data'];

        // Some APIs return data as a list.
        if (data is List && data.isNotEmpty) {
          data = data.first;
        }

        if (data is Map) {
          _name = data['name']?.toString() ?? '';
          _birthdate = data['birthdate']?.toString() ?? '';
          _gender = data['gender']?.toString() ?? '';
          _email = data['email']?.toString() ?? '';
          _phoneNumber =
              data['phone_number']?.toString() ?? '';
          _profileImage =
              data['profile_image']?.toString() ?? '';

          await SessionManager.saveUserSession(
            userId: userId,
            name: _name,
            email: _email,
          );
        }
      } else {
        _errorMessage = response is Map
            ? response['message']?.toString() ??
            'Unable to load profile.'
            : 'Unable to load profile.';
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load profile.';
      });

      debugPrint('Profile error: $e');
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3D354F),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: Color(0xFFF2F0EC),
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Color(0xFFB7B4AE),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFFB7B4AE),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFD7C5D8),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await SessionManager.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Future<void> _openPage(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );

    if (!mounted) return;

    await _loadProfile();
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
          'Profile',
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
      onRefresh: _loadProfile,
      color: const Color(0xFF312A44),
      backgroundColor: const Color(0xFFD7C5D8),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        child: Column(
          children: [
            _buildProfileHeader(),

            const SizedBox(height: 25),

            _buildProfileInfo(),

            const SizedBox(height: 25),

            _buildMenu(),

            const SizedBox(height: 25),

            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Column(
      children: [
        _buildProfileImage(),

        const SizedBox(height: 15),

        Text(
          _name.isEmpty ? 'User' : _name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFF2F0EC),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),

        const SizedBox(height: 5),

        Text(
          _email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFB7B4AE),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget _buildProfileImage() {
    if (_profileImage.isNotEmpty) {
      return CircleAvatar(
        radius: 55,
        backgroundImage: NetworkImage(_profileImage),
        backgroundColor: const Color(0xFF3D354F),
      );
    }

    return const CircleAvatar(
      radius: 55,
      backgroundColor: Color(0xFF3D354F),
      child: Icon(
        Icons.person_rounded,
        size: 60,
        color: Color(0xFFD7C5D8),
      ),
    );
  }

  // ============================================================
  // PROFILE INFORMATION
  // ============================================================

  Widget _buildProfileInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF3D354F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.person_outline,
            'Name',
            _name,
          ),
          _divider(),
          _infoRow(
            Icons.cake_outlined,
            'Birthdate',
            _birthdate,
          ),
          _divider(),
          _infoRow(
            Icons.wc_outlined,
            'Gender',
            _gender,
          ),
          _divider(),
          _infoRow(
            Icons.email_outlined,
            'Email',
            _email,
          ),
          _divider(),
          _infoRow(
            Icons.phone_outlined,
            'Phone',
            _phoneNumber,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFD7C5D8),
          size: 22,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF88708E),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  color: Color(0xFFF2F0EC),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Divider(
        color: Color(0xFF51495F),
        height: 1,
      ),
    );
  }

  // ============================================================
  // MENU
  // ============================================================

  Widget _buildMenu() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3D354F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _menuItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () {
              if (_userId == null) return;

              _openPage(
                EditProfilePage(
                  userId: _userId!,
                ),
              );
            },
          ),
          _menuDivider(),
          _menuItem(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            onTap: () {
              if (_userId == null) return;

              _openPage(
                ChangePasswordPage(
                  userId: _userId!,
                ),
              );
            },
          ),
          _menuDivider(),
          _menuItem(
            icon: Icons.rate_review_outlined,
            title: 'My Reviews',
            onTap: () {
              if (_userId == null) return;

              _openPage(
                MyReviewsPage(
                  userId: _userId!,
                ),
              );
            },
          ),
          _menuDivider(),
          _menuItem(
            icon: Icons.bookmark_border_rounded,
            title: 'My Watchlist',
            onTap: () {
              _openPage(
                const WatchlistPage(),
              );
            },
          ),
          _menuDivider(),
          _menuItem(
            icon: Icons.check_circle_outline_rounded,
            title: 'Watched Movies',
            onTap: () {
              _openPage(
                const WatchedMoviesPage(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 4,
      ),
      leading: Icon(
        icon,
        color: const Color(0xFFD7C5D8),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFF2F0EC),
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF88708E),
      ),
    );
  }

  Widget _menuDivider() {
    return const Divider(
      color: Color(0xFF51495F),
      height: 1,
      indent: 18,
      endIndent: 18,
    );
  }

  // ============================================================
  // LOGOUT BUTTON
  // ============================================================

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(
          Icons.logout_rounded,
        ),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD7C5D8),
          side: const BorderSide(
            color: Color(0xFF88708E),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
              Icons.person_off_outlined,
              size: 60,
              color: Color(0xFFD7C5D8),
            ),
            const SizedBox(height: 18),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFF2F0EC),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadProfile,
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