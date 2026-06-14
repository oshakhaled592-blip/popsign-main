import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'font_weights_helper.dart';

class AppTextStyles {
  static TextStyle font36SemiboldWhite = GoogleFonts.poppins(
    fontWeight: FontWeightHelper.semiBold,
    fontSize: 36,
    color: Colors.white,
  );
  static TextStyle font16boldWhite = GoogleFonts.poppins(
    fontWeight: FontWeightHelper.bold,
    fontSize: 16,
    color: Colors.white,
  );
  static TextStyle font18RegularWhite = GoogleFonts.poppins(
    fontWeight: FontWeightHelper.regular,
    fontSize: 18,
    color: Colors.white,
  );
  static TextStyle font24BoldWhite = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.bold,
    fontSize: 24,
    color: Colors.white,
  );
  static TextStyle font22BoldWhiteInter = GoogleFonts.inter(
    fontWeight: FontWeightHelper.bold,
    fontSize: 22,
    color: Colors.white,
  );
  static TextStyle font13RegularWhiteInter = GoogleFonts.inter(
    fontWeight: FontWeightHelper.regular,
    fontSize: 13,
    color: AppColors.grayText,
  );
  static TextStyle font18RegularWhiteInter = GoogleFonts.inter(
    fontWeight: FontWeightHelper.regular,
    fontSize: 18,
    color: Colors.white,
  );

  static TextStyle font36BoldWhite = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.bold,
    fontSize: 36,
    color: Colors.white,
  );
  static TextStyle font13RegularWhite = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.regular,
    fontSize: 13,
    color: Colors.white,
  );
  static TextStyle font13RegularGray = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.regular,
    fontSize: 13,
    color: AppColors.grayText,
  );
  static TextStyle font17RegularGray = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.regular,
    fontSize: 17,
    color: AppColors.grayText,
  );
  static TextStyle font13Regularpink = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.regular,
    fontSize: 13,
    color: AppColors.linear2,
  );
  static TextStyle font14Boldblack = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.bold,
    fontSize: 14,
    color: AppColors.textButtonColor,
  );
  static TextStyle font13RegularDarkpink = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.regular,
    fontSize: 13,
    color: AppColors.linear1,
  );
  static TextStyle font13Lightpink = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.light,
    fontSize: 13,
    color: AppColors.linear2,
  );
}
