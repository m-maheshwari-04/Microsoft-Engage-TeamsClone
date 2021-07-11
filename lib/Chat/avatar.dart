import 'package:flutter/material.dart';

/// User profile avatar
class Avatar extends StatelessWidget {
  final double width;
  final double height;
  final String url;

  Avatar({this.width = 60.0, this.height = 60.0, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color(0xfff3f2ee),
        shape: BoxShape.circle,
      ),
      child: Container(
        margin: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                fit: BoxFit.cover, image: new NetworkImage(url))),
      ),
    );
  }
}
