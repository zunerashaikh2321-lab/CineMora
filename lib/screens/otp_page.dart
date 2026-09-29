import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import 'reset_password_page.dart';

class OtpPage extends StatefulWidget {
  final String email;
  final String otp;

  const OtpPage({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _otpController =
  TextEditingController();

  final ApiService _apiService = ApiService();

  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _verifyOtp() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {

      final enteredOtp =
      _otpController.text.trim();

      final result =
      await _apiService.verifyOtp(
        email: widget.email,
        otp: enteredOtp,
      );

      if (!mounted) return;

      if (result is Map &&
          result['status']?.toString().toLowerCase() ==
              'success') {

        final data = result['data'];

        if (data is! Map ||
            data['user_id'] == null) {

          _showMessage(
            'User information not found.',
          );

          return;
        }

        final userId =
        data['user_id'].toString();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(
              userId: userId,
              otp: enteredOtp,
            ),
          ),
        );

      } else {

        final message = result is Map
            ? result['message']?.toString() ??
            'Invalid OTP'
            : 'Invalid OTP';

        _showMessage(message);
      }

    } catch (e) {

      if (!mounted) return;

      _showMessage(
        'Something went wrong. Please try again.',
      );

      debugPrint('OTP verification error: $e');

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
          'Verify OTP',
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
                  Icons.verified_user_outlined,
                  size: 72,
                  color: Color(0xFFD7C5D8),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Enter OTP',
                  style: TextStyle(
                    color: Color(0xFFF2F0EC),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Enter the 6-digit OTP generated for\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFB7B4AE),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 25),

                // =================================================
                // TESTING OTP DISPLAY
                // =================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: const Color(0xFF3D354F),
                    borderRadius:
                    BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF88708E),
                    ),
                  ),

                  child: Column(
                    children: [

                      const Text(
                        'Your OTP',
                        style: TextStyle(
                          color: Color(0xFFB7B4AE),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [

                          Text(
                            widget.otp,
                            style: const TextStyle(
                              color: Color(0xFFD7C5D8),
                              fontSize: 26,
                              fontWeight:
                              FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),

                          const SizedBox(width: 10),

                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: widget.otp,
                                ),
                              );

                              _showMessage(
                                'OTP copied.',
                              );
                            },
                            icon: const Icon(
                              Icons.copy_outlined,
                              color:
                              Color(0xFFD7C5D8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                TextFormField(
                  controller: _otpController,

                  keyboardType:
                  TextInputType.number,

                  maxLength: 6,

                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly,
                  ],

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                    fontSize: 20,
                    letterSpacing: 5,
                    fontWeight: FontWeight.bold,
                  ),

                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit OTP',

                    hintStyle:
                    const TextStyle(
                      color: Color(0xFF88708E),
                      fontSize: 14,
                      letterSpacing: 0,
                    ),

                    counterText: '',

                    filled: true,

                    fillColor:
                    const Color(0xFF3D354F),

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide:
                      BorderSide.none,
                    ),

                    enabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide:
                      BorderSide.none,
                    ),

                    focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide:
                      const BorderSide(
                        color:
                        Color(0xFFD7C5D8),
                      ),
                    ),

                    errorBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide:
                      const BorderSide(
                        color: Colors.redAccent,
                      ),
                    ),
                  ),

                  validator: (value) {

                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter OTP';
                    }

                    if (value.trim().length != 6) {
                      return 'OTP must contain 6 digits';
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
                    _isLoading ? null : _verifyOtp,

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
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'After verification, you can create a new password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF88708E),
                    fontSize: 12,
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