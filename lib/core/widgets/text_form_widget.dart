import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/styles.dart';

class TextFormWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final bool? obscureText;
  final bool? autofocus;
  final TextInputType? keyboardType;

  // إضافة validator
  final String? Function(String?)? validator;

  const TextFormWidget({
    super.key,
    required this.controller,
    this.keyboardType,
    required this.hintText,
    this.icon,
    this.obscureText,
    this.autofocus,
    this.validator,
  });

  @override
  State<TextFormWidget> createState() => _TextFormWidgetState();
}

class _TextFormWidgetState extends State<TextFormWidget> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final fillColor  = isDark ? AppColors.darkGray : const Color(0xFFEFF1F8);
    final iconColor  = isDark ? AppColors.grayText : Colors.grey.shade500;
    final inputColor = isDark ? AppColors.grayText : const Color(0xFF374151);

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      style: AppTextStyles.font13RegularGray.copyWith(color: inputColor),
      keyboardType: widget.keyboardType,
      autofocus: widget.autofocus ?? false,
      obscureText: widget.obscureText == true ? _isObscured : false,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: iconColor, size: 20.sp)
            : null,
        suffixIcon: widget.obscureText == true
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
                icon: Icon(
                  _isObscured ? Icons.visibility : Icons.visibility_off,
                  color: iconColor,
                  size: 20.sp,
                ),
              )
            : null,
        hintText: widget.hintText,
        hintStyle: AppTextStyles.font13RegularGray.copyWith(color: iconColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}