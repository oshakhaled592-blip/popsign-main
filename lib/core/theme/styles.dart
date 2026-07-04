import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'font_weights_helper.dart';

class AppTextStyles {
  static TextStyle font36SemiboldWhite = GoogleFonts.poppins(
    fontWeight: FontWeightHelper.semiBold,
    fontSize: 36.sp,
    color: Colors.white,
  );
  static TextStyle font24BoldWhite = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.bold,
    fontSize: 24.sp,
    color: Colors.white,
  );

  static TextStyle font36BoldWhite = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.bold,
    fontSize: 36.sp,
    color: Colors.white,
  );
  static TextStyle font13RegularWhite = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.regular,
    fontSize: 13.sp,
    color: Colors.white,
  );
  static TextStyle font13RegularGray = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.regular,
    fontSize: 13.sp,
    color: AppColors.grayText,
  );
  static TextStyle font17RegularGray = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.regular,
    fontSize: 17.sp,
    color: AppColors.grayText,
  );
  static TextStyle font13Regularpink = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.regular,
    fontSize: 13.sp,
    color: AppColors.linear2,
  );
  static TextStyle font14Boldblack = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.bold,
    fontSize: 14.sp,
    color: AppColors.textButtonColor,
  );
  static TextStyle font13RegularDarkpink = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.regular,
    fontSize: 13.sp,
    color: AppColors.linear1,
  );
  static TextStyle font13Lightpink = GoogleFonts.openSans(
    fontWeight: FontWeightHelper.light,
    fontSize: 13.sp,
    color: AppColors.linear2,
  );
}
