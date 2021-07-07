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
    return Padding(
      padding: EdgeInsets.only(
        left: 10.0.w,
        top: 10.0.h,
        right: 15.0.w
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(height: 55.h,
            width: 55.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: light,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8.0),
              color: isDark ? dark : Colors.white,
            ),
            margin: EdgeInsets.only(bottom: 6.0.h),
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
            width: 25.0.w,
          ),
          Container(
            height: 100.h,
            width: 270.w,
            child: Padding(
              padding: EdgeInsets.only(
                  top: 10.h, bottom: 10.h, left: 15.w, right: 15.w),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$heading',
                      maxLines: 3,
                      style: GoogleFonts.montserrat(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0.sp,
                      ),
                    ),
                    Text(
                      '$desc',
                      maxLines: 3,
                      softWrap: true,
                      style: GoogleFonts.montserrat(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 15.0.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
