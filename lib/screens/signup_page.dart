import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/session_manager.dart';
import 'home_page.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  final ApiService _apiService = ApiService();

  String _gender = '';
  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // AGE LIMIT
  // ============================================================

  DateTime _minimumAllowedBirthdate() {
    final today = DateTime.now();

    return DateTime(
      today.year - 12,
      today.month,
      today.day,
    );
  }

  bool _isAtLeast12YearsOld(DateTime birthdate) {
    final today = DateTime.now();

    int age = today.year - birthdate.year;

    if (today.month < birthdate.month ||
        (today.month == birthdate.month &&
            today.day < birthdate.day)) {
      age--;
    }

    return age >= 12;
  }

  // ============================================================
  // BIRTHDATE PICKER
  // ============================================================

  Future<void> _selectBirthdate() async {
    final today = DateTime.now();
    final maximumBirthdate = _minimumAllowedBirthdate();

    final selectedDate = await showDatePicker(
      context: context,

      // Existing design/flow preserved
      initialDate: DateTime(2005),

      firstDate: DateTime(1950),

      // User must be at least 12 years old
      lastDate: maximumBirthdate,
    );

    if (selectedDate == null) {
      return;
    }

    if (!_isAtLeast12YearsOld(selectedDate)) {
      _showMessage(
        'You must be at least 12 years old to create an account.',
      );
      return;
    }

    setState(() {
      _birthdateController.text =
      '${selectedDate.year}-'
          '${selectedDate.month.toString().padLeft(2, '0')}-'
          '${selectedDate.day.toString().padLeft(2, '0')}';
    });
  }

  // ============================================================
  // SIGNUP
  // ============================================================

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Gender
    if (_gender.isEmpty) {
      _showMessage('Please select your gender');
      return;
    }

    // Terms
    if (!_termsAccepted) {
      _showMessage(
        'Please accept the Terms & Conditions',
      );
      return;
    }

    // Extra DOB validation
    final birthdate = DateTime.tryParse(
      _birthdateController.text.trim(),
    );

    if (birthdate == null) {
      _showMessage('Please select a valid birthdate');
      return;
    }

    // Future date protection
    if (birthdate.isAfter(DateTime.now())) {
      _showMessage('Birthdate cannot be in the future');
      return;
    }

    // 12 years minimum
    if (!_isAtLeast12YearsOld(birthdate)) {
      _showMessage(
        'You must be at least 12 years old to create an account.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.signup(
        name: _nameController.text.trim(),
        birthdate: _birthdateController.text.trim(),
        gender: _gender,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
        termsAccepted: 'true',
        profileImage: '',
      );

      debugPrint('SIGNUP RESPONSE = $response');
      debugPrint(
        'SIGNUP RESPONSE TYPE = ${response.runtimeType}',
      );

      if (!mounted) return;

      // ========================================================
      // SUCCESS
      // ========================================================

      if (response is Map &&
          response['status']?.toString().toLowerCase() ==
              'success') {
        final data = response['data'];

        String userId = '';
        String userName = _nameController.text.trim();
        String userEmail = _emailController.text.trim();

        if (data is Map) {
          userId = data['user_id']?.toString() ?? '';

          if (data['name'] != null) {
            userName = data['name'].toString();
          }

          if (data['email'] != null) {
            userEmail = data['email'].toString();
          }
        }

        // ======================================================
        // SAVE SESSION
        // ======================================================

        if (userId.isNotEmpty) {
          await SessionManager.saveUserSession(
            userId: userId,
            name: userName,
            email: userEmail,
          );
        }

        if (!mounted) return;

        _showMessage(
          response['message']?.toString() ??
              'Account created successfully',
        );

        // Small delay so success message can be seen
        await Future.delayed(
          const Duration(milliseconds: 700),
        );

        if (!mounted) return;

        // ======================================================
        // SIGNUP → HOME
        // ======================================================

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
              (route) => false,
        );
      }

      // ========================================================
      // ERROR RESPONSE
      // ========================================================

      else {
        final message = response is Map
            ? response['message']?.toString() ??
            'Unable to create account'
            : 'Unable to create account';

        _showMessage(message);
      }
    } catch (e) {
      debugPrint('SIGNUP ERROR = $e');

      if (mounted) {
        _showMessage(
          'Something went wrong. Please try again.',
        );
      }
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
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(
        color: Color(0xFF88708E),
      ),

      prefixIcon: Icon(
        icon,
        color: Color(0xFFB7B4AE),
      ),

      suffixIcon: suffixIcon,

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
  // LABEL
  // ============================================================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFF2F0EC),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // UI
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
          'Create Account',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              10,
              24,
              30,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join CineMora',
                  style: TextStyle(
                    color: Color(0xFFF2F0EC),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Create your account and start discovering movies.',
                  style: TextStyle(
                    color: Color(0xFFB7B4AE),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // NAME
                // ==================================================

                _label('Full Name'),

                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,

                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                  ),

                  decoration: _inputDecoration(
                    hintText: 'Enter your name',
                    icon: Icons.person_outline_rounded,
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // BIRTHDATE
                // ==================================================

                _label('Birthdate'),

                TextFormField(
                  controller: _birthdateController,
                  readOnly: true,
                  onTap: _selectBirthdate,

                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                  ),

                  decoration: _inputDecoration(
                    hintText: 'Select your birthdate',
                    icon: Icons.calendar_month_outlined,
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your birthdate';
                    }

                    final date = DateTime.tryParse(value);

                    if (date == null) {
                      return 'Please select a valid birthdate';
                    }

                    if (date.isAfter(DateTime.now())) {
                      return 'Birthdate cannot be in the future';
                    }

                    if (!_isAtLeast12YearsOld(date)) {
                      return 'You must be at least 12 years old';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // GENDER
                // ==================================================

                _label('Gender'),

                DropdownButtonFormField<String>(
                  initialValue:
                  _gender.isEmpty ? null : _gender,

                  dropdownColor: const Color(0xFF3D354F),

                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                  ),

                  decoration: _inputDecoration(
                    hintText: 'Select gender',
                    icon: Icons.wc_outlined,
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

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your gender';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // EMAIL
                // ==================================================

                _label('Email'),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,

                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                  ),

                  decoration: _inputDecoration(
                    hintText: 'Enter your email',
                    icon: Icons.email_outlined,
                  ),

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

                const SizedBox(height: 18),

                // ==================================================
                // PASSWORD
                // ==================================================

                _label('Password'),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,

                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                  ),

                  decoration: _inputDecoration(
                    hintText: 'Create a password',
                    icon: Icons.lock_outline_rounded,

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                          !_obscurePassword;
                        });
                      },

                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,

                        color: const Color(0xFFB7B4AE),
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // CONFIRM PASSWORD
                // ==================================================

                _label('Confirm Password'),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,

                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                  ),

                  decoration: _inputDecoration(
                    hintText: 'Confirm your password',
                    icon: Icons.lock_reset_outlined,

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                          !_obscureConfirmPassword;
                        });
                      },

                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,

                        color: const Color(0xFFB7B4AE),
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }

                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // PHONE
                // ==================================================

                _label('Phone Number'),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,

                  style: const TextStyle(
                    color: Color(0xFFF2F0EC),
                  ),

                  decoration: _inputDecoration(
                    hintText: 'Enter your phone number',
                    icon: Icons.phone_outlined,
                  ).copyWith(
                    counterText: '',
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }

                    if (value.trim().length != 10) {
                      return 'Enter a valid 10-digit phone number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // ==================================================
                // TERMS
                // ==================================================

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Checkbox(
                      value: _termsAccepted,

                      activeColor:
                      const Color(0xFFD7C5D8),

                      checkColor:
                      const Color(0xFF312A44),

                      side: const BorderSide(
                        color: Color(0xFFB7B4AE),
                      ),

                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                    ),

                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),

                        child: Text(
                          'I agree to the Terms & Conditions and Privacy Policy.',

                          style: TextStyle(
                            color: Color(0xFFB7B4AE),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ==================================================
                // CREATE ACCOUNT
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton(
                    onPressed:
                    _isLoading ? null : _signup,

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFD7C5D8),

                      foregroundColor:
                      const Color(0xFF312A44),

                      disabledBackgroundColor:
                      const Color(0xFF88708E),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
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
                        strokeWidth: 2,
                        color: Color(0xFF312A44),
                      ),
                    )
                        : const Text(
                      'Create Account',

                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // LOGIN
                // ==================================================

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                          const LoginPage(),
                        ),
                      );
                    },

                    child: const Text(
                      'Already have an account? Login',

                      style: TextStyle(
                        color: Color(0xFFD7C5D8),
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