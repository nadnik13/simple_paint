import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomFormField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;

  const CustomFormField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.errorText,
  });

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF131313).withAlpha(63),
                    border: Border.all(
                      width: 0.5,
                      color:
                          hasError
                              ? Colors.red.withValues(alpha: 0.7)
                              : Color(0xFF87858F),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Color(0x34E3E3E3).withAlpha(51)),
                      BoxShadow(
                        color: Color(0xFF131313),
                        blurRadius: 40,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color:
                                hasError
                                    ? Colors.red.withValues(alpha: 0.8)
                                    : Color(0xFF87858F),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),

                        TextFormField(
                          controller: widget.controller,
                          obscureText: widget.obscureText,
                          keyboardType: widget.keyboardType,
                          textInputAction: widget.textInputAction,
                          validator: widget.validator,
                          onChanged: widget.onChanged,
                          focusNode: _focusNode,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: _isFocused ? Color(0xFF87858F) : Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            errorText: null,
                            hintText: widget.hintText,
                            hintStyle: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Color(0xFF87858F),
                              fontWeight: FontWeight.w400,
                            ),
                            floatingLabelStyle: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Color(0xFF87858F),
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: EdgeInsets.only(bottom: 2),
                            isDense: true,
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                width: 0.3,
                                color:
                                    hasError
                                        ? Colors.red.withValues(alpha: 0.7)
                                        : Color(0xFF87858F),
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                width: 0.3,
                                color:
                                    hasError
                                        ? Colors.red.withValues(alpha: 0.7)
                                        : Color(0xFF87858F),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                width: 0.3,
                                color:
                                    hasError
                                        ? Colors.red.withValues(alpha: 0.7)
                                        : Color(0xFF87858F),
                              ),
                            ),
                          ),
                        ),

                        if (hasError) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.errorText!,
                            style: GoogleFonts.roboto(
                              fontSize: 11,
                              color: Colors.red.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
