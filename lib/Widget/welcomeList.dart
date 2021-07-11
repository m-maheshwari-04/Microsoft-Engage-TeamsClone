import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_clone/constants.dart';

/// Get started page list items
class WelcomeList extends StatelessWidget {
  WelcomeList({
    required this.img,
    required this.heading,
  });
  final String img;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 70.h,
            width: 70.h,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: FittedBox(
                child: Container(
                  child: Image(
                    height: 120.h,
                    image: AssetImage('images/' + img),
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8.0.w,
          ),
          AutoSizeText(
            '$heading',
            style: GoogleFonts.montserrat(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 16.0.sp,
            ),
          ),
        ],
      ),
    );
  }
}
