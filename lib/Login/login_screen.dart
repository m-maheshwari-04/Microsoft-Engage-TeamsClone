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

/// Login Screen widget
///
/// - Login with email(OTP authentication)
/// - Login with phone(OTP authentication)
/// - Login with Google
///
class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    isDark = themeChangeProvider.darkTheme;
    setState(() {});
  }

  /// UI of login screen
  Widget build(BuildContext context) {
    /// Initialize firebase authentication for the app
    Authentication.initializeFirebase(context: context);

    /// Portrait mode only
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    return SafeArea(
      child: Scaffold(
        backgroundColor: dark,

        /// Setting loader
        body: ProgressHUD(
          indicatorColor: primary,
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
  /// Variable used for selecting login type
  /// 1- email
  /// 2 - phone
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
            "Teams",
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
                    primary: loginType == 1 ? primary : light),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Text(
                    "Email",
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: loginType == 1
                            ? Colors.white
                            : isDark
                                ? Colors.white
                                : Colors.black87),
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
                    primary: loginType == 2 ? primary : light),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  child: Text(
                    "Phone",
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: loginType == 2
                            ? Colors.white
                            : isDark
                                ? Colors.white
                                : Colors.black87),
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
            ?

            /// Login with email
            Column(
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
            :

            /// Login with phone
            Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10, right: 10, left: 10),
                    child: TextField(
                      cursorColor: isDark ? Colors.white70 : Colors.black87,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        prefix: Padding(
                          padding: EdgeInsets.all(4),
                          child: Text(
                            '+91',
                            style: GoogleFonts.montserrat(color: Colors.grey),
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
                        fontWeight: FontWeight.w400,
                        fontSize: 17.0,
                        color: isDark ? Colors.white : Colors.black,
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

        /// Login with Google
        googleSignInButton(),
      ],
    );
  }

  Widget googleSignInButton() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: OutlinedButton(
        style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            backgroundColor: MaterialStateColor.resolveWith((states) => dark)),
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
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage("images/google_logo.png"),
                height: 25.0,
              ),
              Text(
                "    Continue with Google",
                style: GoogleFonts.montserrat(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Email login
  Widget _buildSignIn(String buttonText) {
    return TextButton(
        child: Text(
          buttonText,
          style: GoogleFonts.montserrat(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 17.0,
          ),
        ),
        onPressed: () async {
          if (email.text.isEmpty || password.text.isEmpty) {
            toast("Please fill all the fields");
            return;
          }

          if (password.text.length < 6) {
            toast("Minimum password length is 6 characters");
            return;
          }

          progress.show();
          FirebaseAuth auth = FirebaseAuth.instance;
          try {
            /// Verify credentials from firebase
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

  /// Email input field
  Widget _buildEmail(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        cursorColor: isDark ? Colors.white70 : Colors.black87,
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

  /// Password input field
  Widget _buildPassword(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        cursorColor: isDark ? Colors.white70 : Colors.black87,
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

  /// Send OTP to email
  void sendOtp() async {
    EmailAuth.sessionName = "Teams";
    var data = await EmailAuth.sendOtp(receiverMail: email.text);
    print(data);
    if (data) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => OTPScreen('', email.text, password.text)));
    }
  }
}
