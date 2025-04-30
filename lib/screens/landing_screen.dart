import 'dart:async';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:lankapay_shared_kyc/constants/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';

class LandingScreen extends StatefulWidget {
  LandingScreen();

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          return;
        }
        SystemNavigator.pop();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: appBackgroundColor,
          body: Container(
            width: size.width,
            height: size.height,
        
            child: Column(
              children: [
                SizedBox(height: 50),
                Text(
                  "Shared KYC",
                  style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.displayMedium,
                    fontSize: Responsive.isMobileSmall(context)
                        ? 35
                        : Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 40
                            : 45,
                    fontWeight: FontWeight.w700,
                    color: buttonColor,
                    // color: Colors.grey[300],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  "Know Your Customer",
                  style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.displayMedium,
                    fontSize: Responsive.isMobileSmall(context)
                        ? 28
                        : Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 30
                            : 30,
                    fontWeight: FontWeight.w700,
                    color: buttonColor,
                    // color: Colors.grey[300],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: Image.asset(
                    // "assets/images/kyc_slider.png",
                    "assets/images/lankapay_logo2.jpg",
                    width: 200,
                    height: 200,
                  ),
                ),
                SizedBox(height: 100),
                Text(
                  "Version " + "0.0.1",
                  style: GoogleFonts.lato(
                      textStyle: Theme.of(context).textTheme.displayMedium,
                      fontSize: Responsive.isMobileSmall(context)
                          ? 18
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? 20
                              : 28,
                      fontWeight: FontWeight.w700,
                      // color: Colors.grey[300],
                      color: buttonColor),
                ),
                SizedBox(height: 10),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
          ),
        ),
      ),
    );
  }
}
