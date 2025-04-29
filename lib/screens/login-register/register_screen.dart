import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:lankapay_shared_kyc/constants/responsive.dart';
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/dialogs.dart';

class RegsiterScreen extends StatefulWidget {
  const RegsiterScreen({super.key});

  @override
  State<RegsiterScreen> createState() => _RegsiterScreenState();
}

class _RegsiterScreenState extends State<RegsiterScreen> {
  late SharedPreferences storage;
  final emailController = TextEditingController(text: "");
  final firstnameController = TextEditingController(text: "");
  final lastnameController = TextEditingController(text: "");
  final passwordController = TextEditingController(text: "");
  final confirmPasswordController = TextEditingController(text: "");
  final poneNumberController = TextEditingController(text: "");

  bool _obscureText = true;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String KEY_USERNAME = "KEY_USERNAME";
  final String KEY_EMAIL = "KEY_EMAIL";
  final String KEY_PASSWORD = "KEY_PASSWORD";
  final String KEY_COMPANY = "KEY_COMPANY";
  final String KEY_LOCAL_AUTH_ENABLED = "KEY_LOCAL_AUTH_ENABLED";
  final String REQUIRE_BIOMETRIC_LOGIN_SELECT_YES =
      "REQUIRE_BIOMETRIC_LOGIN_SELECT_YES";
  RegExp regex = new RegExp(r'^.{3,}$');
  var localAuth = LocalAuthentication();

  @override
  void initState() {
    sharedPrefrences();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _seeOrHidePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> sharedPrefrences() async {
    String? isLocalAuthEnabled =
        await _secureStorage.read(key: "KEY_LOCAL_AUTH_ENABLED");

    if (isLocalAuthEnabled == "true") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Biometric authentication is enabled.",
          style: TextStyle(
            fontSize: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 15
                : Responsive.isTabletPortrait(context)
                    ? 20
                    : 20,
          ),
          textScaler: TextScaler.linear(1),
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 5),
        content: Text(
          "Biometric authentication is disabled.",
          style: TextStyle(
            fontSize: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? 15
                : Responsive.isTabletPortrait(context)
                    ? 20
                    : 20,
          ),
          textScaler: TextScaler.linear(1),
        ),
      ));
    }
  }

  void okRecognition() {
    closeDialog(context);
  }

  Widget emailTextField() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 5.0
            : Responsive.isTabletPortrait(context)
                ? size.width * 0.01
                : size.width * 0.02,
      ),
      child: TextFormField(
        controller: emailController,
        autofocus: false,
        onSaved: (value) {
          emailController.text = value!;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
            fontSize: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? size.width * 0.045
                : Responsive.isTabletPortrait(context)
                    ? size.width * 0.028
                    : size.width * 0.045,
            height: 1,
            color: normalTextColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: textFiledFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: buttonColor!,
            ),
          ),
          labelText: "Enter your email",
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(
            color: Colors.grey,
            fontSize: Responsive.isMobileSmall(context)
                ? size.width * 0.042
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.04
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.02
                        : size.width * 0.04,
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 40),
          prefixIcon: Icon(
            color: buttonColor,
            Icons.email,
            size: Responsive.isMobileSmall(context)
                ? size.width * 0.06
                : Responsive.isMobileMedium(context)
                    ? size.width * 0.06
                    : Responsive.isMobileLarge(context)
                        ? size.width * 0.06
                        : Responsive.isTabletPortrait(context)
                            ? size.width * 0.035
                            : size.width * 0.025,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return ("Email is required..");
          }
          return null;
        },
      ),
    );
  }

  Widget firstnameTextField() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 5.0
            : Responsive.isTabletPortrait(context)
                ? size.width * 0.01
                : size.width * 0.02,
      ),
      child: TextFormField(
        controller: firstnameController,
        autofocus: false,
        onSaved: (value) {
          firstnameController.text = value!;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.name,
        style: TextStyle(
            fontSize: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? size.width * 0.045
                : Responsive.isTabletPortrait(context)
                    ? size.width * 0.028
                    : size.width * 0.045,
            height: 1,
            color: normalTextColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: textFiledFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: buttonColor!,
            ),
          ),
          labelText: "Enter your first name",
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(
            color: Colors.grey,
            fontSize: Responsive.isMobileSmall(context)
                ? size.width * 0.042
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.04
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.02
                        : size.width * 0.04,
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 40),
          prefixIcon: Icon(
            color: buttonColor,
            Icons.person,
            size: Responsive.isMobileSmall(context)
                ? size.width * 0.06
                : Responsive.isMobileMedium(context)
                    ? size.width * 0.06
                    : Responsive.isMobileLarge(context)
                        ? size.width * 0.06
                        : Responsive.isTabletPortrait(context)
                            ? size.width * 0.035
                            : size.width * 0.025,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "First name is required.";
          }
          return null;
        },
      ),
    );
  }

  Widget lastnameTextField() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 5.0
            : Responsive.isTabletPortrait(context)
                ? size.width * 0.01
                : size.width * 0.02,
      ),
      child: TextFormField(
        controller: lastnameController,
        autofocus: false,
        onSaved: (value) {
          lastnameController.text = value!;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.name,
        style: TextStyle(
            fontSize: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? size.width * 0.045
                : Responsive.isTabletPortrait(context)
                    ? size.width * 0.028
                    : size.width * 0.045,
            height: 1,
            color: normalTextColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: textFiledFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: buttonColor!,
            ),
          ),
          labelText: "Enter your last name",
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(
            color: Colors.grey,
            fontSize: Responsive.isMobileSmall(context)
                ? size.width * 0.042
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.04
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.02
                        : size.width * 0.04,
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 40),
          prefixIcon: Icon(
            color: buttonColor,
            Icons.person,
            size: Responsive.isMobileSmall(context)
                ? size.width * 0.06
                : Responsive.isMobileMedium(context)
                    ? size.width * 0.06
                    : Responsive.isMobileLarge(context)
                        ? size.width * 0.06
                        : Responsive.isTabletPortrait(context)
                            ? size.width * 0.035
                            : size.width * 0.025,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Last name is required.";
          }
          return null;
        },
      ),
    );
  }

  Widget passwordTextField() {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.isMobileSmall(context) ||
                Responsive.isMobileMedium(context) ||
                Responsive.isMobileLarge(context)
            ? 5.0
            : Responsive.isTabletPortrait(context)
                ? size.width * 0.01
                : size.width * 0.02,
      ),
      child: TextFormField(
        controller: passwordController,
        autofocus: false,
        onSaved: (value) {
          passwordController.text = value!;
          FocusScope.of(context).unfocus();
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.visiblePassword,
        obscureText: _obscureText,
        style: TextStyle(
            fontSize: Responsive.isMobileSmall(context) ||
                    Responsive.isMobileMedium(context) ||
                    Responsive.isMobileLarge(context)
                ? size.width * 0.045
                : Responsive.isTabletPortrait(context)
                    ? size.width * 0.028
                    : size.width * 0.045,
            height: 1,
            color: normalTextColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: textFiledFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey, width: 0.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: buttonColor!,
            ),
          ),
          labelText: "Enter your password",
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(
            color: Colors.grey,
            fontSize: Responsive.isMobileSmall(context)
                ? size.width * 0.042
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? size.width * 0.04
                    : Responsive.isTabletPortrait(context)
                        ? size.width * 0.02
                        : size.width * 0.04,
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 40),
          prefixIcon: Icon(
            color: buttonColor,
            Icons.lock,
            size: Responsive.isMobileSmall(context)
                ? size.width * 0.06
                : Responsive.isMobileMedium(context)
                    ? size.width * 0.06
                    : Responsive.isMobileLarge(context)
                        ? size.width * 0.06
                        : Responsive.isTabletPortrait(context)
                            ? size.width * 0.035
                            : size.width * 0.025,
          ),
          suffixIcon: IconButton(
            color: buttonColor,
            onPressed: _seeOrHidePassword,
            icon: Icon(
              _obscureText == true ? Icons.visibility_off : Icons.visibility,
              size: Responsive.isMobileSmall(context)
                  ? size.width * 0.06
                  : Responsive.isMobileMedium(context)
                      ? size.width * 0.06
                      : Responsive.isMobileLarge(context)
                          ? size.width * 0.06
                          : Responsive.isTabletPortrait(context)
                              ? size.width * 0.035
                              : size.width * 0.025,
            ),
          ),
        ),
        validator: (value) {
          RegExp regex = new RegExp(r'^.{3,}$');
          if (value == null || value.isEmpty) {
            return ("Password is required.");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password");
          }
          if (value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: appBackgroundColor2,
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Image.asset(
                          'assets/images/lankapay_logo2.jpg',
                          width: Responsive.isMobileSmall(context) ? 120 : 90,
                          height: Responsive.isMobileSmall(context) ? 75 : 75,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Form(
                            key: _key,
                            child: Column(
                              children: <Widget>[
                                Center(
                                    child: Text(
                                  "Register",
                                  style: TextStyle(
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? 30
                                        : Responsive.isMobileMedium(context)
                                            ? 30
                                            : Responsive.isMobileLarge(context)
                                                ? 30
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 40
                                                    : 40,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'First Name',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: normalTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                                firstnameTextField(),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Last Name',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: normalTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                                lastnameTextField(),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Email',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: normalTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                                emailTextField(),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Password',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: normalTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                                passwordTextField(),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                            child: Text(
                              "Regsiter",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: actionButtonTextColor,
                                fontSize: Responsive.isMobileSmall(context)
                                    ? size.width * 0.042
                                    : Responsive.isMobileMedium(context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 20
                                        : Responsive.isTabletPortrait(context)
                                            ? size.width * 0.03
                                            : size.width * 0.06,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fixedSize: Responsive.isMobileSmall(context)
                                  ? Size(size.width, 45)
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? Size(size.width, 50)
                                      : Responsive.isTabletPortrait(context)
                                          ? Size(size.width, 55)
                                          : Size(size.width, 60),
                            ),
                            onPressed: () {}),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            "OR",
                            style:
                                TextStyle(fontSize: 20, color: normalTextColor),
                          ),
                        ),
                        GoogleAuthButton(
                          materialStyle: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.white70),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.black),
                          ),
                          onPressed: () {},
                          style: AuthButtonStyle(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 70, vertical: 10),
                              iconType: AuthIconType.secondary,
                              textStyle: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(height: 25),
                        Align(
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account ? ",
                              style: TextStyle(
                                fontSize: Responsive.isMobileSmall(context)
                                    ? 13
                                    : Responsive.isMobileMedium(context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 15
                                        : Responsive.isTabletPortrait(context)
                                            ? 16
                                            : 19,
                                color: cardColor,
                                fontWeight: FontWeight.w600,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Login",
                                  style: TextStyle(
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? 15
                                        : Responsive.isMobileMedium(context)
                                            ? 17
                                            : Responsive.isMobileLarge(context)
                                                ? 19
                                                : Responsive.isTabletPortrait(
                                                        context)
                                                    ? 22
                                                    : 24,
                                    color: cardColor,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
