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
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      style: AppTextStyles.font13RegularGray,
      keyboardType: widget.keyboardType,
      autofocus: widget.autofocus ?? false,
      obscureText: widget.obscureText == true ? _isObscured : false,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.darkGray,
        prefixIcon: widget.icon != null
            ? Icon(
                widget.icon,
                color: AppColors.grayText,
              )
            : null,
        suffixIcon: widget.obscureText == true
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
                icon: Icon(
                  _isObscured
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.grayText,
                ),
              )
            : null,
        hintText: widget.hintText,
        hintStyle: AppTextStyles.font13RegularGray,
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
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}