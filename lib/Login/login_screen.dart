import 'dart:io';
import 'dart:ui';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Auth/otp.dart';
import 'package:team_clone/Widget/Toast.dart';
import 'package:team_clone/nav_bar_file.dart';
import 'package:team_clone/Login/AfterLogin/Welcome.dart';
import 'Auth/Google.dart';
import 'package:team_clone/constants.dart';
import 'package:team_clone/main.dart';

ScrollController _scrollController = ScrollController();
bool showError = false;
var progress;


class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  bool scrolled = false;

  _scrollListener() {
    if (!scrolled && MediaQuery.of(context).viewInsets.bottom != 0) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
      scrolled = true;
    }
    if (MediaQuery.of(context).viewInsets.bottom == 0) {
      scrolled = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    isDark = themeChangeProvider.darkTheme;
    setState(() {});
  }

  Widget build(BuildContext context) {
    Authentication.initializeFirebase(context: context);

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? dark : Colors.white,
        body: ProgressHUD(
          indicatorColor: isDark ? Colors.white : light,
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          child: Builder(builder: (context) {
            progress = ProgressHUD.of(context);
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(child: LoginFormWidget()),
            );
          }),
        ),
      ),
    );
  }
}

class LoginFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginFormWidgetState();
  }
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  int loginType = 1;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();

  var emailFocusNode = FocusNode();
  var passwordFocusNode = FocusNode();
  bool isPasswordVisible = true;

  bool autoValidate = false;

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 50.0),
          child: Text(
            "Microsoft Teams",
            style: GoogleFonts.montserrat(
                fontStyle: FontStyle.normal,
                fontSize: 28,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          child: Image(
            height: 300.h,
            image: AssetImage('images/login.png'),
            fit: BoxFit.scaleDown,
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    primary: light.withOpacity(loginType == 1 ? 1 : 0.5)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Text(
                    "Email",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    loginType = 1;
                  });
                }),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    primary: light.withOpacity(loginType == 2 ? 1 : 0.5)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Text(
                    "Phone",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    loginType = 2;
                  });
                }),
          ],
        ),
        SizedBox(
          height: 10.h,
        ),
        loginType == 1
            ? Column(
                children: [
                  _buildEmail(context),
                  _buildPassword(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSignIn("Sign Up"),
                      _buildSignIn("Sign In"),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10, right: 10, left: 10),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        prefix: Padding(
                          padding: EdgeInsets.all(4),
                          child: Text(
                            '+91',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      controller: phone,
                    ),
                  ),
                  TextButton(
                    child: Text(
                      "Send OTP",
                      style: GoogleFonts.montserrat(
                        color: isDark ? Colors.white : light,
                        fontWeight: FontWeight.w400,
                        fontSize: 17.0,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => OTPScreen(phone.text, '', '')));
                    },
                  ),
                ],
              ),
        SizedBox(
          height: 30.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            redirectSignInButton(img: 'google_logo.png'),
            SizedBox(width: 20),
            redirectSignInButton(img: 'microsoft_logo.png'),
          ],
        ),
      ],
    );
  }

  Widget redirectSignInButton({required String img}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: OutlinedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        onPressed: () async {
          progress.show();
          User? user = await Authentication.signInWithGoogle(context: context);
          progress.dismiss();

          if (user != null) {
            currentUser = user;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Welcome()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Image(
            image: AssetImage("images/$img"),
            height: 35.0,
          ),
        ),
      ),
    );
  }

  Widget _buildSignIn(String buttonText) {
    return TextButton(
        child: Text(
          buttonText,
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : light,
            fontWeight: FontWeight.w400,
            fontSize: 17.0,
          ),
        ),
        onPressed: () async {
          if (email.text.isEmpty || password.text.isEmpty) {
            toast("Invalid Details ... Try again");

            return;
          }
          progress.show();
          FirebaseAuth auth = FirebaseAuth.instance;
          try {
            final UserCredential userCredential =
                await auth.signInWithEmailAndPassword(
                    email: email.text, password: password.text);
            currentUser = userCredential.user;

            if (currentUser!.displayName == null ||
                currentUser!.photoURL == null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Welcome()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => NavBarClass(0)),
              );
            }
          } on FirebaseAuthException catch (e) {
            switch (e.code) {
              case "user-not-found":
                {
                  if (buttonText == 'Sign In') {
                    toast('User not registered');
                    break;
                  }
                  toast('Verify your email');
                  sendOtp();
                  break;
                }
              default:
                toast('Invalid Credentials');
            }
          }
          progress.dismiss();
        });
  }

  Widget _buildEmail(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: email,
        decoration: InputDecoration(
          hintText: 'Email',
          prefixIcon: Icon(
            Icons.account_circle_sharp,
            color: Colors.grey,
          ),
          alignLabelWithHint: true,
        ),
        textInputAction: TextInputAction.done,
      ),
    );
  }

  Widget _buildPassword(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Password',
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.grey,
          ),
          alignLabelWithHint: true,
          suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              }),
        ),
        obscureText: isPasswordVisible,
        controller: password,
      ),
    );
  }

  void sendOtp() async {
    EmailAuth.sessionName = "Team Clone";
    var data = await EmailAuth.sendOtp(receiverMail: email.text);
    print(data);
    if (data) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => OTPScreen('', email.text, password.text)));
    }
  }
}
