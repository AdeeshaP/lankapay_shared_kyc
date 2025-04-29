import 'dart:convert';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lankapay_shared_kyc/api-services/api_access.dart';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:lankapay_shared_kyc/constants/responsive.dart';
import 'package:lankapay_shared_kyc/utils/dialogs.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late SharedPreferences storage;
  final TextEditingController usernameController =
      TextEditingController(text: "");
  final TextEditingController passwordController =
      TextEditingController(text: "");
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
    Future.delayed(Duration(seconds: 3), () {
      _readFromStorage();
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
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

  // Read values
  Future<void> _readFromStorage() async {
    String isLocalAuthEnabled =
        await _secureStorage.read(key: "KEY_LOCAL_AUTH_ENABLED") ?? "false";

    if ("true" == isLocalAuthEnabled) {
      bool didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Please authenticate to sign in',
          options: const AuthenticationOptions(useErrorDialogs: false));

      if (didAuthenticate) {
        usernameController.text =
            await _secureStorage.read(key: KEY_USERNAME) ?? '';
        passwordController.text =
            await _secureStorage.read(key: KEY_PASSWORD) ?? '';

        _login(usernameController.text, passwordController.text);
      }
    } else {
      usernameController.text = '';
      passwordController.text = '';
    }
  }

  Future<void> _login(String userName, String pword) async {
    storage = await SharedPreferences.getInstance();
    if (_key.currentState!.validate()) {
      final request = await ApiService.loginUser(userName, pword);

      if (request != null) {
        if (request.statusCode == 200) {
          final responseBody = jsonDecode(request.body);
          String token = responseBody['token'];

          storage.setString('token', token); // Save token

          await _secureStorage.write(
              key: KEY_USERNAME, value: usernameController.text.trim());
          await _secureStorage.write(
              key: KEY_PASSWORD, value: passwordController.text);

          print("Login Successful: $responseBody");

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => HomePage(email: usernameController.text),
          //   ),
          // );
        } else {
          showWarningDialogPopup(
            context,
            Icons.warning,
            "Login Failed.!! \nUsername or password is wrong.",
            okRecognition,
            // Color.fromARGB(255, 237, 172, 10),
          );
        }
      } else {
        showWarningDialogPopup(
          context,
          Icons.warning,
          "Login Failed.!! \nSystem Error.",
          okRecognition,
          // Color.fromARGB(255, 237, 172, 10),
        );
      }
    }
  }

  void okRecognition() {
    closeDialog(context);
  }

  Widget usernameTextField() {
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
        controller: usernameController,
        autofocus: false,
        onSaved: (value) {
          usernameController.text = value!;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.name,
        style: TextStyle(
            fontSize: Responsive.isMobileSmall(context)
                ? 15
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 17
                    : Responsive.isTabletPortrait(context)
                        ? 20
                        : 22,
            height: 1,
            color: normalTextColor),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: buttonColor!,
            ),
          ),
          labelText: "Enter the username",
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
          floatingLabelBehavior: FloatingLabelBehavior.never,
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
            return 'Please enter your email/ username';
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
            fontSize: Responsive.isMobileSmall(context)
                ? 15
                : Responsive.isMobileMedium(context) ||
                        Responsive.isMobileLarge(context)
                    ? 17
                    : Responsive.isTabletPortrait(context)
                        ? 20
                        : 22,
            height: 1,
            color: normalTextColor),
        decoration: InputDecoration(
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
          labelText: "Enter the password",
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
          floatingLabelBehavior: FloatingLabelBehavior.never,
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
          if (value!.isEmpty) {
            return ("Password is required.");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password(Min. 3 Character)");
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
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            // gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            //   Colors.cyan[500]!,
            //   Colors.cyan[300]!,
            //   Colors.cyan[400]!
            // ]),
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
                        padding: const EdgeInsets.symmetric(vertical: 25.0),
                        child: Image.asset(
                          'assets/images/lankapay_logo2.jpg',
                          width: Responsive.isMobileSmall(context) ? 120 : 120,
                          height: Responsive.isMobileSmall(context) ? 75 : 100,
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
                  padding: EdgeInsets.all(20),
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
                                "Login",
                                style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 35
                                      : Responsive.isMobileMedium(context)
                                          ? 40
                                          : Responsive.isMobileLarge(context)
                                              ? 40
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? 50
                                                  : 50,
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Username',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: normalTextColor,
                                    ),
                                  ),
                                ),
                              ),
                              usernameTextField(),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            child: Text(
                              "Sign in",
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
                            onPressed: () {
                              _login(usernameController.text,
                                  passwordController.text);
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
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
                          foregroundColor: WidgetStatePropertyAll(Colors.black),
                        ),
                        onPressed: () {},
                        style: AuthButtonStyle(
                            padding: EdgeInsets.symmetric(
                                horizontal: 65, vertical: 10),
                            iconType: AuthIconType.secondary,
                            textStyle: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(height: 50),
                      Align(
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              fontSize: Responsive.isMobileSmall(context)
                                  ? 13
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? 15
                                      : Responsive.isTabletPortrait(context)
                                          ? 16
                                          : 19,
                              color: normalTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: " Register Now",
                                style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 15
                                      : Responsive.isMobileMedium(context)
                                          ? 17
                                          : Responsive.isMobileLarge(context)
                                              ? 19
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? 16
                                                  : 19,
                                  color: normalTextColor,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         RegsiterScreen(),
                                    //   ),
                                    // );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

// import 'dart:convert';
// import 'package:shared_kyc_app/constants/constants.dart';
// import 'package:shared_kyc_app/screens/Login-Register/register_temperary.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:shared_kyc_app/API-Access/api_service.dart';
// import 'package:shared_kyc_app/constants/dimensions.dart';
// import 'package:shared_kyc_app/utils/dialogs.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Home/home_page.dart';
// import 'package:auth_buttons/auth_buttons.dart';
// import 'package:local_auth/local_auth.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   late SharedPreferences storage;
//   final TextEditingController usernameController =
//       TextEditingController(text: "");
//   final TextEditingController passwordController =
//       TextEditingController(text: "");
//   bool _obscureText = true;
//   final GlobalKey<FormState> _key = GlobalKey<FormState>();
//   FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//   final String KEY_USERNAME = "KEY_USERNAME";
//   final String KEY_EMAIL = "KEY_EMAIL";
//   final String KEY_PASSWORD = "KEY_PASSWORD";
//   final String KEY_COMPANY = "KEY_COMPANY";
//   final String KEY_LOCAL_AUTH_ENABLED = "KEY_LOCAL_AUTH_ENABLED";
//   final String REQUIRE_BIOMETRIC_LOGIN_SELECT_YES =
//       "REQUIRE_BIOMETRIC_LOGIN_SELECT_YES";
//   RegExp regex = new RegExp(r'^.{3,}$');
//   var localAuth = LocalAuthentication();

//   @override
//   void initState() {
//     sharedPrefrences();
//     super.initState();
//     Future.delayed(Duration(seconds: 3), () {
//       _readFromStorage();
//     });
//   }

//   @override
//   void dispose() {
//     usernameController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   void _seeOrHidePassword() {
//     setState(() {
//       _obscureText = !_obscureText;
//     });
//   }

//   Future<void> sharedPrefrences() async {
//     String? isLocalAuthEnabled =
//         await _secureStorage.read(key: "KEY_LOCAL_AUTH_ENABLED");

//     if (isLocalAuthEnabled == "true") {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text(
//           "Biometric authentication is enabled.",
//           style: TextStyle(
//             fontSize: Responsive.isMobileSmall(context) ||
//                     Responsive.isMobileMedium(context) ||
//                     Responsive.isMobileLarge(context)
//                 ? 15
//                 : Responsive.isTabletPortrait(context)
//                     ? 20
//                     : 20,
//           ),
//           textScaler: TextScaler.linear(1),
//         ),
//       ));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         duration: Duration(seconds: 5),
//         content: Text(
//           "Biometric authentication is disabled.",
//           style: TextStyle(
//             fontSize: Responsive.isMobileSmall(context) ||
//                     Responsive.isMobileMedium(context) ||
//                     Responsive.isMobileLarge(context)
//                 ? 15
//                 : Responsive.isTabletPortrait(context)
//                     ? 20
//                     : 20,
//           ),
//           textScaler: TextScaler.linear(1),
//         ),
//       ));
//     }
//   }

//   // Read values
//   Future<void> _readFromStorage() async {
//     String isLocalAuthEnabled =
//         await _secureStorage.read(key: "KEY_LOCAL_AUTH_ENABLED") ?? "false";

//     if ("true" == isLocalAuthEnabled) {
//       bool didAuthenticate = await localAuth.authenticate(
//           localizedReason: 'Please authenticate to sign in',
//           options: const AuthenticationOptions(useErrorDialogs: false));

//       if (didAuthenticate) {
//         usernameController.text =
//             await _secureStorage.read(key: KEY_USERNAME) ?? '';
//         passwordController.text =
//             await _secureStorage.read(key: KEY_PASSWORD) ?? '';

//         _login(usernameController.text, passwordController.text);
//       }
//     } else {
//       usernameController.text = '';
//       passwordController.text = '';
//     }
//   }

//   Future<void> _login(String userName, String pword) async {
//     storage = await SharedPreferences.getInstance();
//     if (_key.currentState!.validate()) {
//       final request = await ApiService.loginUser(userName, pword);

//       if (request != null) {
//         if (request.statusCode == 200) {
//           final responseBody = jsonDecode(request.body);
//           String token = responseBody['token'];

//           storage.setString('token', token); // Save token

//           await _secureStorage.write(
//               key: KEY_USERNAME, value: usernameController.text.trim());
//           await _secureStorage.write(
//               key: KEY_PASSWORD, value: passwordController.text);

//           print("Login Successful: $responseBody");

//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => HomePage(email: usernameController.text),
//             ),
//           );
//         } else {
//           showWarningDialogPopup(
//             context,
//             Icons.warning,
//             "Login Failed.!! \nUsername or password is wrong.",
//             okRecognition,
//             // Color.fromARGB(255, 237, 172, 10),
//           );
//         }
//       } else {
//         showWarningDialogPopup(
//           context,
//           Icons.warning,
//           "Login Failed.!! \nSystem Error.",
//           okRecognition,
//           // Color.fromARGB(255, 237, 172, 10),
//         );
//       }
//     }
//   }

//   void okRecognition() {
//     closeDialog(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;

//     return PopScope(
//       canPop: true,
//       onPopInvokedWithResult: (didPop, dynamic) {
//         if (!didPop) {
//           return;
//         }
//         SystemNavigator.pop();
//       },
//       child: SafeArea(
//           child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         backgroundColor: appBackgroundColor2,
//         body: Container(
//           height: size.height,
//           // decoration: BoxDecoration(
//           //   image: DecorationImage(
//           //     image: NetworkImage(
//           //         "https://i.pinimg.com/736x/91/ea/b7/91eab724c3f7ac487a6f54d4dec7d685.jpg"),
//           //     fit: BoxFit.cover,
//           //     opacity: 0.3,
//           //   ),
//           // ),
//           child: SingleChildScrollView(
//             child: Column(children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 25),
//                 child: Image.asset(
//                   'assets/images/lankapay_logo2.jpg',
//                   width: Responsive.isMobileSmall(context) ? 160 : 140,
//                   height: Responsive.isMobileSmall(context) ? 120 : 85,
//                 ),
//               ),
//               Center(
//                 child: Form(
//                   key: _key,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: cardColor3,
//                     ),
//                     padding: EdgeInsets.symmetric(horizontal: 10.0),
//                     margin: EdgeInsets.symmetric(horizontal: 10.0),
//                     child: Column(children: [
//                       SizedBox(height: size.width * 0.02),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10.0),
//                         child: Text(
//                           "Login",
//                           style: TextStyle(
//                             fontSize: Responsive.isMobileSmall(context)
//                                 ? 22
//                                 : Responsive.isMobileMedium(context)
//                                     ? 25
//                                     : Responsive.isMobileLarge(context)
//                                         ? 28
//                                         : Responsive.isTabletPortrait(context)
//                                             ? 24
//                                             : 25,
//                             fontWeight: FontWeight.w800,
//                             color: cardColor,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Padding(
//                         padding: EdgeInsets.only(bottom: 5, left: 10, right: 8),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             'Username',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                               color: normalTextColor,
//                             ),
//                           ),
//                         ),
//                       ),
//                       usernameTextField(),
//                       Padding(
//                         padding: EdgeInsets.only(
//                             top: 10, bottom: 5, left: 10, right: 8),
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text(
//                             'Password',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                               color: normalTextColor,
//                             ),
//                           ),
//                         ),
//                       ),
//                       passwordTextField(),
//                       SizedBox(height: 15),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: ElevatedButton(
//                             child: Text(
//                               "Sign in",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: actionButtonTextColor,
//                                 fontSize: Responsive.isMobileSmall(context)
//                                     ? size.width * 0.042
//                                     : Responsive.isMobileMedium(context) ||
//                                             Responsive.isMobileLarge(context)
//                                         ? 20
//                                         : Responsive.isTabletPortrait(context)
//                                             ? size.width * 0.03
//                                             : size.width * 0.06,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: buttonColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                               fixedSize: Responsive.isMobileSmall(context)
//                                   ? Size(size.width, 45)
//                                   : Responsive.isMobileMedium(context) ||
//                                           Responsive.isMobileLarge(context)
//                                       ? Size(size.width, 50)
//                                       : Responsive.isTabletPortrait(context)
//                                           ? Size(size.width, 55)
//                                           : Size(size.width, 60),
//                             ),
//                             onPressed: () {
//                               _login(usernameController.text,
//                                   passwordController.text);
//                             }),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 15.0),
//                         child: Text(
//                           "OR",
//                           style:
//                               TextStyle(fontSize: 20, color: normalTextColor),
//                         ),
//                       ),
//                       GoogleAuthButton(
//                         materialStyle: ButtonStyle(
//                           backgroundColor: WidgetStatePropertyAll(Colors.white),
//                           foregroundColor: WidgetStatePropertyAll(Colors.black),
//                         ),
//                         onPressed: () {},
//                         style: AuthButtonStyle(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 65, vertical: 10),
//                             iconType: AuthIconType.secondary,
//                             textStyle: TextStyle(
//                                 fontSize: 17, fontWeight: FontWeight.w600)),
//                       ),
//                       SizedBox(height: 50),
//                       Align(
//                         alignment: Alignment.center,
//                         child: RichText(
//                           text: TextSpan(
//                             text: "Don't have an account? ",
//                             style: TextStyle(
//                               fontSize: Responsive.isMobileSmall(context)
//                                   ? 13
//                                   : Responsive.isMobileMedium(context) ||
//                                           Responsive.isMobileLarge(context)
//                                       ? 15
//                                       : Responsive.isTabletPortrait(context)
//                                           ? 16
//                                           : 19,
//                               color: cardColor,
//                               fontWeight: FontWeight.w600,
//                             ),
//                             children: <TextSpan>[
//                               TextSpan(
//                                 text: " Register Now",
//                                 style: TextStyle(
//                                   fontSize: Responsive.isMobileSmall(context)
//                                       ? 15
//                                       : Responsive.isMobileMedium(context)
//                                           ? 17
//                                           : Responsive.isMobileLarge(context)
//                                               ? 19
//                                               : Responsive.isTabletPortrait(
//                                                       context)
//                                                   ? 16
//                                                   : 19,
//                                   color: cardColor,
//                                   fontWeight: FontWeight.w800,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                                 recognizer: TapGestureRecognizer()
//                                   ..onTap = () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             // RegisterScreen(),
//                                             RegisterTemperoryScreen(),
//                                       ),
//                                     );
//                                   },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       )
//                     ]),
//                   ),
//                 ),
//               ),
//             ]),
//           ),
//         ),
//       )),
//     );
//   }
