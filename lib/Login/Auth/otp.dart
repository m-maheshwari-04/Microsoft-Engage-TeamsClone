import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:team_clone/Widget/Toast.dart';
import 'package:team_clone/constants.dart';
import 'package:team_clone/Login/AfterLogin/Welcome.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_clone/nav_bar_file.dart';

/// OTP screen widget
///
/// - verify OTP for email or phone
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

  /// Controller for OTP
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: light,
    border: new Border.all(width: 1.0, color: Color.fromRGBO(0, 0, 0, 0.1)),
    borderRadius: new BorderRadius.circular(10.0),
  );

  /// Send OTP to number provided by user
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
      /// If password is empty it means it phone authentication
      _verifyPhone();
    }
  }

  /// UI of OTP screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,
      appBar: AppBar(
          title: Text('OTP Verification', style: GoogleFonts.montserrat())),
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
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, fontSize: 24),
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
              textStyle:
                  GoogleFonts.montserrat(fontSize: 25.0, color: Colors.black87),
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

          /// Keys for OTP input
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        OTPKeys(text: "1", pinPutController: _pinPutController),
                        OTPKeys(text: "2", pinPutController: _pinPutController),
                        OTPKeys(text: "3", pinPutController: _pinPutController),
                      ],
                    ),
                  ),
                ),
                new Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        OTPKeys(text: "4", pinPutController: _pinPutController),
                        OTPKeys(text: "5", pinPutController: _pinPutController),
                        OTPKeys(text: "6", pinPutController: _pinPutController),
                      ],
                    ),
                  ),
                ),
                new Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        OTPKeys(text: "7", pinPutController: _pinPutController),
                        OTPKeys(text: "8", pinPutController: _pinPutController),
                        OTPKeys(text: "9", pinPutController: _pinPutController),
                      ],
                    ),
                  ),
                ),
                new Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 4.0, right: 8.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          color: light,
                          child: Icon(
                            Icons.backspace,
                            size: 24.0,
                          ),
                        ),
                        OTPKeys(text: "0", pinPutController: _pinPutController),
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
                            color: light,
                            child: Icon(
                              Icons.done_rounded,
                              size: 24.0,
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
        ],
      ),
    );
  }

  /// Verifying OTP provided by user
  void otpMatch(pin) async {
    try {
      if (widget.password.isEmpty) {
        /// Phone number verification
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
        /// Email verification
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
      toast('Invalid OTP');
    }
  }
}

/// UI of input keys (OTP)
class OTPKeys extends StatelessWidget {
  final String text;
  final TextEditingController pinPutController;

  OTPKeys({
    required this.text,
    required this.pinPutController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: MaterialButton(
        onPressed: () {
          pinPutController.text += text;
        },
        padding: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: light,
        child: Text(text,
            style: GoogleFonts.montserrat(
                fontSize: 25.0, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center),
      ),
    );
  }
}
