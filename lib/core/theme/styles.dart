import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'font_weights_helper.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle title(BuildContext context) => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeightHelper.bold,
        color: Theme.of(context).textTheme.bodyLarge!.color,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeightHelper.regular,
        color: Theme.of(context).textTheme.bodyMedium!.color,
      );

  static TextStyle small(BuildContext context) => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeightHelper.regular,
        color: AppColors.grey,
      );

  static TextStyle button(BuildContext context) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeightHelper.bold,
        color: Colors.white,
      );
}