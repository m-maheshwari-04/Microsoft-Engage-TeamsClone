import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:team_clone/constants.dart';

class SidebarTile extends StatelessWidget {
  final pageName;
  final page;
  final newPage;
  SidebarTile(this.pageName, this.page, this.newPage);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(
            left: 15.0, right: 15.0, top: 4.0, bottom: 4.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: isDark ? darkShadow : lightShadow,
            color: light.withOpacity(0.8),
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
          ),
          child: Container(
            margin: EdgeInsets.only(left: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? dark : Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 150,
                              child: AutoSizeText(pageName,
                                  style: GoogleFonts.montserrat(
                                    color: isDark ? Colors.white : Colors.black,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        if (newPage) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => page),
          );
        }
        else{
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },

    );
  }
}
