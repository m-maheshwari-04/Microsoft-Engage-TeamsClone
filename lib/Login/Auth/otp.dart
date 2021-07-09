import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:team_clone/constants.dart';
import 'package:team_clone/Login/AfterLogin/Welcome.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_clone/nav_bar_file.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String email;
  final String password;
  OTPScreen(this.phone, this.email, this.password);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String? _verificationCode;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: Color(0XFFECEDF5),
    border: new Border.all(width: 1.0, color: Color.fromRGBO(0, 0, 0, 0.1)),
    borderRadius: new BorderRadius.circular(10.0),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? dark : Colors.white,
      appBar: AppBar(
        title: Text('OTP Verification',style: GoogleFonts.montserrat())
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: Text(
                widget.password.isEmpty
                    ? 'Verify +91 ${widget.phone}'
                    : 'Verify your email ${widget.email}',
                style:GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            child: Image(
              height: 200.h,
              image: AssetImage('images/otp.png'),
              fit: BoxFit.scaleDown,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: PinPut(
              fieldsCount: 6,
              textStyle: GoogleFonts.montserrat(fontSize: 25.0, color: Colors.black),
              eachFieldWidth: 40.0,
              eachFieldHeight: 55.0,
              focusNode: _pinPutFocusNode,
              controller: _pinPutController,
              autofocus: false,
              enabled: false,
              submittedFieldDecoration: pinPutDecoration,
              selectedFieldDecoration: pinPutDecoration,
              followingFieldDecoration: pinPutDecoration,
              disabledDecoration: pinPutDecoration,
              pinAnimationType: PinAnimationType.fade,
              onSubmit: otpMatch,
            ),
          ),
          Expanded(child: Container()),
          Container(
            padding: EdgeInsets.symmetric(vertical: 30.h),
            width: double.infinity,
            decoration: BoxDecoration(
                boxShadow: !isDark ? lightShadowTop : darkShadowTop,
                color: !isDark ? Color(0XFFECEDF5) : dark,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35))),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 9.0, right: 8.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: MaterialButton(
                            onPressed: () {
                              _pinPutController.text += "1";
                            },
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: !isDark ? Colors.white : dark,
                            child: Text("1",
                                style:GoogleFonts.montserrat(
                                    color:
                                        !isDark ? Colors.black : Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: MaterialButton(
                            onPressed: () {
                              _pinPutController.text += "2";
                            },
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: !isDark ? Colors.white : dark,
                            child: Text("2",
                                style:GoogleFonts.montserrat(
                                    color:
                                        !isDark ? Colors.black : Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: MaterialButton(
                            onPressed: () {
                              _pinPutController.text += "3";
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            color: !isDark ? Colors.white : dark,
                            child: Text("3",
                                style:GoogleFonts.montserrat(
                                    color:
                                        !isDark ? Colors.black : Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                new Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: MaterialButton(
                            onPressed: () {
                              _pinPutController.text += "4";
                            },
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: !isDark ? Colors.white : dark,
                            child: Text("4",
                                style:GoogleFonts.montserrat(
                                    color:
                                        !isDark ? Colors.black : Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: MaterialButton(
                            onPressed: () {
                              _pinPutController.text += "5";
                            },
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: !isDark ? Colors.white : dark,
                            child: Text("5",
                                style:GoogleFonts.montserrat(
                                    color:
                                        !isDark ? Colors.black : Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: MaterialButton(
                            onPressed: () {
                              _pinPutController.text += "6";
                            },
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: !isDark ? Colors.white : dark,
                            child: Text("6",
                                style:GoogleFonts.montserrat(
                                    color:
                                        !isDark ? Colors.black : Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                new Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: MaterialButton(
                            onPressed: () {
                              _pinPutController.text += "7";
                            },
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: !isDark ? Colors.white : dark,
                            child: Text("7",
                                style: GoogleFonts.montserrat(
                                    color:
                                        !isDark ? Colors.black : Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 5),
                          child: MaterialButton(
                            onPressed: () {
                              _pinPutController.text += "8";
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            color: !isDark ? Colors.white : dark,
                            child: Text("8",
                                style:GoogleFonts.montserrat(
                                    color:
                                        !isDark ? Colors.black : Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: MaterialButton(
                            onPressed: () {
                              _pinPutController.text += "9";
                            },
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: !isDark ? Colors.white : dark,
                            child: Text("9",
                                style: GoogleFonts.montserrat(
                                    color:
                                        !isDark ? Colors.black : Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                new Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            if (_pinPutController.text.length > 6) {
                              _pinPutController.text =
                                  _pinPutController.text.substring(0, 6);
                            }
                            if (_pinPutController.text.length != 0) {
                              _pinPutController.text = _pinPutController.text
                                  .substring(
                                      0, _pinPutController.text.length - 1);
                            }
                          },
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: !isDark ? Colors.white : dark,
                          child: Icon(Icons.backspace,
                              size: 24.0,
                              color: !isDark ? Colors.black : Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: MaterialButton(
                            onPressed: () {
                              _pinPutController.text += "0";
                            },
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: !isDark ? Colors.white : dark,
                            child: Text("0",
                                style:GoogleFonts.montserrat(
                                    color:
                                        !isDark ? Colors.black : Colors.white,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: MaterialButton(
                            onPressed: () {
                              if (_pinPutController.text.length > 6) {
                                _pinPutController.text =
                                    _pinPutController.text.substring(0, 6);
                              }
                              otpMatch(_pinPutController.text);
                            },
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: !isDark ? Colors.white : dark,
                            child: Icon(Icons.done_rounded,
                                size: 24.0,
                                color: !isDark ? Colors.black : Colors.white),
                          ),
                        ),
                      ],
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

  void otpMatch(pin) async {
    try {
      if (widget.password.isEmpty) {
        await FirebaseAuth.instance
            .signInWithCredential(PhoneAuthProvider.credential(
                verificationId: _verificationCode!, smsCode: pin))
            .then((value) async {
          if (value.user != null) {
            currentUser = value.user;
            if (currentUser!.displayName == null ||
                currentUser!.photoURL == null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Welcome()),
                  (route) => false);
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => NavBarClass(0)),
                  (route) => false);
            }
          }
        });
      } else {
        bool valid =
            EmailAuth.validate(userOTP: pin, receiverMail: widget.email);
        if (valid) {
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: widget.email, password: widget.password)
              .then((value) async {
            if (value.user != null) {
              currentUser = value.user;

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Welcome()),
                  (route) => false);
            }
          });
        }
      }
    } catch (e) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('invalid OTP')));
    }
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phone}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Welcome()),
                  (route) => false);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verficationID, int? resendToken) {
          setState(() {
            _verificationCode = verficationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 120));
  }

  @override
  void initState() {
    super.initState();
    if (widget.password.isEmpty) {
      _verifyPhone();
    }
  }
}
