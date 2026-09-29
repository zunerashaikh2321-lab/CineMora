import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/session_manager.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ApiService _apiService = ApiService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();
  final TextEditingController _birthdateController =
  TextEditingController();
  final TextEditingController _emailController =
  TextEditingController();
  final TextEditingController _phoneController =
  TextEditingController();

  String _gender = '';

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD USER FROM API
  // ============================================================

  Future<void> _loadUser() async {
    try {
      final response =
      await _apiService.getUser(widget.userId);

      if (!mounted) return;

      if (response is Map &&
          response['status']?.toString().toLowerCase() ==
              'success') {
        dynamic data = response['data'];

        if (data is List && data.isNotEmpty) {
          data = data.first;
        }

        if (data is Map) {
          _nameController.text =
              data['name']?.toString() ?? '';

          _birthdateController.text =
              data['birthdate']?.toString() ?? '';

          _emailController.text =
              data['email']?.toString() ?? '';

          _phoneController.text =
              data['phone_number']?.toString() ?? '';

          _gender =
              data['gender']?.toString() ?? '';
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

      debugPrint('Edit profile load error: $e');
    }
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await _apiService.updateProfile(
        userId: widget.userId,
        name: _nameController.text.trim(),
        birthdate: _birthdateController.text.trim(),
        gender: _gender,
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (response is Map &&
          response['status']?.toString().toLowerCase() ==
              'success') {
        await SessionManager.saveUserSession(
          userId: widget.userId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully.'),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response is Map
                  ? response['message']?.toString() ??
                  'Unable to update profile.'
                  : 'Unable to update profile.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );

      debugPrint('Update profile error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
          'Edit Profile',
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
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(
            color: Color(0xFFF2F0EC),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter your name';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            _buildTextField(
              controller: _birthdateController,
              label: 'Birthdate',
              icon: Icons.cake_outlined,
            ),

            const SizedBox(height: 18),

            _buildGenderDropdown(),

            const SizedBox(height: 18),

            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType:
              TextInputType.emailAddress,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter your email';
                }

                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 30),

            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: Color(0xFFF2F0EC),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFFB7B4AE),
        ),
        prefixIcon: Icon(
          icon,
          color: Color(0xFFD7C5D8),
        ),
        filled: true,
        fillColor: const Color(0xFF3D354F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD7C5D8),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GENDER
  // ============================================================

  Widget _buildGenderDropdown() {
    final validGender = [
      'Male',
      'Female',
      'Other',
    ].contains(_gender)
        ? _gender
        : null;

    return DropdownButtonFormField<String>(
      initialValue: validGender,
      dropdownColor: const Color(0xFF3D354F),
      style: const TextStyle(
        color: Color(0xFFF2F0EC),
      ),
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: const TextStyle(
          color: Color(0xFFB7B4AE),
        ),
        prefixIcon: const Icon(
          Icons.wc_outlined,
          color: Color(0xFFD7C5D8),
        ),
        filled: true,
        fillColor: const Color(0xFF3D354F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: 'Male',
          child: Text('Male'),
        ),
        DropdownMenuItem(
          value: 'Female',
          child: Text('Female'),
        ),
        DropdownMenuItem(
          value: 'Other',
          child: Text('Other'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _gender = value ?? '';
        });
      },
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD7C5D8),
          foregroundColor: const Color(0xFF312A44),
          disabledBackgroundColor:
          const Color(0xFF88708E),
          padding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF312A44),
          ),
        )
            : const Text(
          'Save Changes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
