import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {

  final String userId;
  final String otp;

  const ResetPasswordPage({
    super.key,
    required this.userId,
    required this.otp,
  });

  @override
  State<ResetPasswordPage> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState
    extends State<ResetPasswordPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController
  _confirmPasswordController =
  TextEditingController();

  final ApiService _apiService = ApiService();

  bool _isLoading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  Future<void> _resetPassword() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {

      final newPassword =
      _passwordController.text.trim();

      final result =
      await _apiService.resetPassword(
        userId: widget.userId,
        otp: widget.otp,
        newPassword: newPassword,
      );

      if (!mounted) return;

      if (result is Map &&
          result['status']?.toString().toLowerCase() ==
              'success') {

        _showMessage(
          'Password reset successfully.',
        );

        await Future.delayed(
          const Duration(milliseconds: 800),
        );

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
              (route) => false,
        );

      } else {

        final message = result is Map
            ? result['message']?.toString() ??
            'Password reset failed.'
            : 'Password reset failed.';

        _showMessage(message);
      }

    } catch (e) {

      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
      );

      debugPrint(
        'Reset password error: $e',
      );

    } finally {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Color(0xFFF2F0EC),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF3D354F),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    required VoidCallback onToggle,
    required bool obscure,
  }) {
    return InputDecoration(

      hintText: hintText,

      hintStyle: const TextStyle(
        color: Color(0xFF88708E),
      ),

      prefixIcon: Icon(
        icon,
        color: const Color(0xFFB7B4AE),
      ),

      suffixIcon: IconButton(
        onPressed: onToggle,

        icon: Icon(
          obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,

          color: const Color(0xFFB7B4AE),
        ),
      ),

      filled: true,

      fillColor: const Color(0xFF3D354F),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFD7C5D8),
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
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
          'Reset Password',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            45,
            24,
            30,
          ),

          child: Form(
            key: _formKey,

            child: Column(
              children: [

                const Icon(
                  Icons.lock_reset_outlined,
                  size: 72,
                  color: Color(0xFFD7C5D8),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Create New Password',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Color(0xFFF2F0EC),
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Enter a new password for your CineMora account.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Color(0xFFB7B4AE),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 35),

                // =================================================
                // NEW PASSWORD
                // =================================================

                Align(
                  alignment: Alignment.centerLeft,

                  child: const Text(
                    'New Password',
                    style: TextStyle(
                      color: Color(0xFFF2F0EC),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _passwordController,

                  obscureText: _obscurePassword,

                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                  ),

                  decoration: _inputDecoration(
                    hintText: 'Enter new password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscurePassword,
                    onToggle: () {
                      setState(() {
                        _obscurePassword =
                        !_obscurePassword;
                      });
                    },
                  ),

                  validator: (value) {

                    if (value == null ||
                        value.isEmpty) {
                      return 'Please enter a new password';
                    }

                    if (value.length < 6) {
                      return 'Password must contain at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // =================================================
                // CONFIRM PASSWORD
                // =================================================

                Align(
                  alignment: Alignment.centerLeft,

                  child: const Text(
                    'Confirm Password',
                    style: TextStyle(
                      color: Color(0xFFF2F0EC),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller:
                  _confirmPasswordController,

                  obscureText:
                  _obscureConfirmPassword,

                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                  ),

                  decoration: _inputDecoration(
                    hintText: 'Confirm new password',
                    icon: Icons.lock_outline_rounded,
                    obscure:
                    _obscureConfirmPassword,
                    onToggle: () {
                      setState(() {
                        _obscureConfirmPassword =
                        !_obscureConfirmPassword;
                      });
                    },
                  ),

                  validator: (value) {

                    if (value == null ||
                        value.isEmpty) {
                      return 'Please confirm your password';
                    }

                    if (value !=
                        _passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // =================================================
                // RESET BUTTON
                // =================================================

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton(
                    onPressed:
                    _isLoading
                        ? null
                        : _resetPassword,

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFD7C5D8),

                      foregroundColor:
                      const Color(0xFF312A44),

                      disabledBackgroundColor:
                      const Color(0xFF88708E),

                      elevation: 0,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color:
                        Color(0xFF312A44),
                      ),
                    )
                        : const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}