import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomFormField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
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
    this.validator,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
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
                    border: Border.all(width: 0.5, color: Color(0xFF87858F)),
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
                          label,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Color(0xFF87858F),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),

                        TextFormField(
                          controller: controller,
                          obscureText: obscureText,
                          keyboardType: keyboardType,
                          validator: validator,
                          onChanged: onChanged,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Color(0xFF87858F),
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            errorText: errorText,
                            hintText: hintText,
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
                                color: Color(0xFF87858F),
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                width: 0.3,
                                color: Color(0xFF87858F),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                width: 0.3,
                                color: Color(0xFF87858F),
                              ),
                            ),
                          ),
                        ),
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
