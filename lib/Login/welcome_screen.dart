import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team_clone/Widget/carousel_item.dart';
import 'package:team_clone/constants.dart';
import 'package:team_clone/main.dart';
import 'package:team_clone/Login/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _current = 0;
  Color colorPrimary = light;
  CarouselController buttonCarouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    isDark = themeChangeProvider.darkTheme;
    print(isDark);
    setState(() {});
  }

  List<Widget> carouselList = [
    CarouselItem(
      title: 'Microsoft Teams',
      subtitle: 'Meeting Time!',
      colour: Colors.white,
      image: '1.png',
    ),
    CarouselItem(
      title: 'Microsoft Teams',
      subtitle:
          'Get started with your work, school or personal Microsoft account',
      colour: Colors.white,
      image: '2.png',
    ),
    CarouselItem(
      title: 'Microsoft Teams',
      subtitle: 'Get reminders for your scheduled meetings',
      colour: Colors.white,
      image: '3.png',
    )
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      backgroundColor: isDark ? dark : Colors.white,
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              items: carouselList,
              options: CarouselOptions(
                  enableInfiniteScroll: false,
                  autoPlay: false,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  height: double.infinity,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  }),
              carouselController: buttonCarouselController,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: carouselList.map((item) {
                        int index = carouselList.indexOf(item);
                        return Container(
                          width: 9.0,
                          height: 9.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 3.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _current == index
                                ? Color(0xFF0C0D13)
                                : Color(0xFF8085A7),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                FlatButton(
                  color: _current == carouselList.length - 1
                      ? colorPrimary
                      : colorPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  onPressed: () async {
                    await Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ));
                    // exit(0);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35.0, vertical: 12),
                    child: Text(
                      'Login',
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
