import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/styles.dart';

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
    return TextFormField(
      controller: widget.controller,
      style: AppTextStyles.body(context),
      keyboardType: widget.keyboardType,
      autofocus: widget.autofocus ?? false,
      validator: widget.validator,
      obscureText: widget.obscureText == true ? _isObscured : false,

      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,

        prefixIcon: widget.icon != null
            ? Icon(widget.icon)
            : null,

        suffixIcon: widget.obscureText == true
            ? IconButton(
                onPressed: () =>
                    setState(() => _isObscured = !_isObscured),
                icon: Icon(
                  _isObscured
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              )
            : null,

        hintText: widget.hintText,
        hintStyle: AppTextStyles.small(context),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}