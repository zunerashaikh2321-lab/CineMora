import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppInputDecoration {
  AppInputDecoration._();

  static InputDecoration decoration({
    required String hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,

      filled: true,
      fillColor: AppColors.darkGrey,

      hintStyle: const TextStyle(
        color: AppColors.grey,
        fontFamily: 'Georgia',
      ),

      labelStyle: const TextStyle(
        color: AppColors.silverWisteria,
        fontFamily: 'Georgia',
      ),

      prefixIconColor: AppColors.duskyLilac,
      suffixIconColor: AppColors.duskyLilac,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),

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
          color: AppColors.duskyLilac,
          width: 1.2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.2,
        ),
      ),

      errorStyle: const TextStyle(
        color: AppColors.error,
        fontFamily: 'Georgia',
      ),
    );
  }
}