import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'otp_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final ApiService _apiService = ApiService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND OTP
  // ============================================================

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();

      final response = await _apiService.forgotPassword(
        email: email,
      );

      if (!mounted) return;

      debugPrint(
        'FORGOT PASSWORD API RESPONSE: $response',
      );

      if (response is Map &&
          response['status']?.toString().toLowerCase() ==
              'success') {

        final data = response['data'];

        if (data is! Map || data['otp'] == null) {
          _showMessage('OTP not received.');
          return;
        }

        final otp = data['otp'].toString();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(
              email: email,
              otp: otp,
            ),
          ),
        );

      } else {

        final message = response is Map
            ? response['message']?.toString() ??
            'Unable to generate OTP.'
            : 'Unable to generate OTP.';

        _showMessage(message);
      }

    } catch (e) {

      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
      );

      debugPrint(
        'FORGOT PASSWORD ERROR: $e',
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

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: 'Enter your registered email',

      hintStyle: const TextStyle(
        color: Color(0xFF88708E),
      ),

      prefixIcon: const Icon(
        Icons.email_outlined,
        color: Color(0xFFB7B4AE),
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
          'Forgot Password',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 30,
            ),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  const Center(
                    child: Icon(
                      Icons.lock_reset_outlined,
                      size: 75,
                      color: Color(0xFFD7C5D8),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Center(
                    child: Text(
                      'Reset your password',
                      style: TextStyle(
                        color: Color(0xFFF2F0EC),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Enter the email address connected to your CineMora account. We will generate an OTP for verification.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB7B4AE),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    'Email',
                    style: TextStyle(
                      color: Color(0xFFF2F0EC),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _emailController,
                    keyboardType:
                    TextInputType.emailAddress,

                    style: const TextStyle(
                      color: Color(0xFFF2F0EC),
                    ),

                    decoration: _inputDecoration(),

                    validator: (value) {

                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter your email';
                      }

                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(
                      onPressed:
                      _isLoading ? null : _sendOtp,

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
                        height: 22,
                        width: 22,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                          Color(0xFF312A44),
                        ),
                      )
                          : const Text(
                        'Send OTP',
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
      ),
    );
  }
}