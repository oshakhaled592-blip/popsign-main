import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

class TextFormWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final bool? obscureText;
  final bool? autofocus;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const TextFormWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.obscureText,
    this.autofocus,
    this.keyboardType,
    this.validator,
  });

  @override
  State<TextFormWidget> createState() => _TextFormWidgetState();
}

class _TextFormWidgetState extends State<TextFormWidget> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      autofocus: widget.autofocus ?? false,
      validator: widget.validator,
      obscureText: widget.obscureText == true ? _isObscured : false,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        fontSize: 15.sp,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),

        prefixIcon: widget.icon != null
            ? Icon(widget.icon,
                color: isDark ? Colors.white38 : Colors.grey.shade500,
                size: 20.sp)
            : null,

        suffixIcon: widget.obscureText == true
            ? IconButton(
                onPressed: () =>
                    setState(() => _isObscured = !_isObscured),
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                  size: 20.sp,
                ),
              )
            : null,

        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : Colors.grey.shade400,
          fontSize: 14.sp,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
