import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_clone/constants.dart';

class WelcomeList extends StatelessWidget {
  WelcomeList({
    required this.img,
    required this.heading,
    required this.desc,
  });
  final String img;
  final String heading;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 55.h,
          width: 55.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: light,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8.0),
            color: isDark ? dark : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: FittedBox(
              child: Container(
                child: Image(
                  height: 80.h,
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
        Container(
          width: 270.w,
          child: Padding(
            padding: EdgeInsets.only(
                top: 20.h, bottom: 20.h, left: 15.w, right: 15.w),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '$heading',
                    style: GoogleFonts.montserrat(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0.sp,
                    ),
                  ),
                  SizedBox(height: 5),
                  AutoSizeText(
                    '$desc',
                    maxLines: 3,
                    softWrap: true,
                    style: GoogleFonts.montserrat(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 15.0.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
