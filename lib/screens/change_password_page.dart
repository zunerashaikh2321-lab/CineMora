import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final String userId;

  const ChangePasswordPage({
    super.key,
    required this.userId,
  });

  @override
  State<ChangePasswordPage> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState
    extends State<ChangePasswordPage> {
  final ApiService _apiService = ApiService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController =
  TextEditingController();

  final TextEditingController _newPasswordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isSaving = false;

  bool _hideOldPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      final response = await _apiService.changePassword(
        userId: widget.userId,
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      if (response is Map &&
          response['status']?.toString().toLowerCase() ==
              'success') {
        _showMessage(
          'Password changed successfully.',
        );

        Navigator.pop(context);
      } else {
        final message = response is Map
            ? response['message']?.toString() ??
            'Unable to change password.'
            : 'Unable to change password.';

        _showMessage(message);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
      );

      debugPrint('Change password error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
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
          'Change Password',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Text(
                'Update your password',
                style: TextStyle(
                  color: Color(0xFFF2F0EC),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter your current password and choose a new password.',
                style: TextStyle(
                  color: Color(0xFFB7B4AE),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              _buildPasswordField(
                controller: _oldPasswordController,
                label: 'Current Password',
                obscureText: _hideOldPassword,
                onVisibilityPressed: () {
                  setState(() {
                    _hideOldPassword =
                    !_hideOldPassword;
                  });
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Enter your current password';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _buildPasswordField(
                controller: _newPasswordController,
                label: 'New Password',
                obscureText: _hideNewPassword,
                onVisibilityPressed: () {
                  setState(() {
                    _hideNewPassword =
                    !_hideNewPassword;
                  });
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Enter a new password';
                  }

                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _buildPasswordField(
                controller:
                _confirmPasswordController,
                label: 'Confirm New Password',
                obscureText: _hideConfirmPassword,
                onVisibilityPressed: () {
                  setState(() {
                    _hideConfirmPassword =
                    !_hideConfirmPassword;
                  });
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Confirm your new password';
                  }

                  if (value !=
                      _newPasswordController.text) {
                    return 'Passwords do not match';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              _buildChangeButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PASSWORD FIELD
  // ============================================================

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onVisibilityPressed,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        color: Color(0xFFF2F0EC),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFFB7B4AE),
        ),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: Color(0xFFD7C5D8),
        ),
        suffixIcon: IconButton(
          onPressed: onVisibilityPressed,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFFB7B4AE),
          ),
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
  // BUTTON
  // ============================================================

  Widget _buildChangeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
        _isSaving ? null : _changePassword,
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
          'Change Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}