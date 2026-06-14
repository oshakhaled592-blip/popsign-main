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
  const TextFormWidget({
    super.key,
    required this.controller,
    this.keyboardType,
    required this.hintText,
    this.icon,
    this.obscureText,
    this.autofocus,
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
      style: AppTextStyles.font13RegularGray,
      keyboardType: widget.keyboardType,
      autofocus: widget.autofocus ?? false,
      obscureText: widget.obscureText == true ? _isObscured : false,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.darkGray,
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: AppColors.grayText)
            : null,
        suffixIcon: widget.obscureText == true
            ? IconButton(
                onPressed: () => setState(() => _isObscured = !_isObscured),
                icon: Icon(
                  _isObscured ? Icons.visibility : Icons.visibility_off,
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
      ),
    );
  }
}
