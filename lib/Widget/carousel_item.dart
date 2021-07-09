import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CarouselItem extends StatelessWidget {
  CarouselItem(
      {required this.title,
      required this.subtitle,
      required this.colour,
      required this.image});
  final String title;
  final String subtitle;
  final Color colour;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 25.0,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
        Image(
          height: 400,
          image: AssetImage('images/$image'),
          fit: BoxFit.scaleDown,
        ),
        Padding(
          padding: EdgeInsets.only(top: 25.0),
          child: Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 18.0,
            ),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}
