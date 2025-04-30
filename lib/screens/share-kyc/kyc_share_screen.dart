import 'package:another_flushbar/flushbar.dart';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';

import '../../constants/responsive.dart';

class KYCShareScreen extends StatefulWidget {
  const KYCShareScreen({super.key});

  @override
  State<KYCShareScreen> createState() => _KYCShareScreenState();
}

class _KYCShareScreenState extends State<KYCShareScreen> {
  final int notificationCount = 1;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: appBarIconColor,
          ),
        ),
        automaticallyImplyLeading: true,
        elevation: 10,
        centerTitle: true,
        actions: <Widget>[
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 6),
            badgeContent: Text(
              notificationCount > 99 ? '99+' : '$notificationCount',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            showBadge: notificationCount > 0,
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: appBarIconColor,
                size: 25,
              ),
              onPressed: () async {
                await Flushbar(
                  backgroundColor: buttonColor!,
                  reverseAnimationCurve: Curves.decelerate,
                  flushbarPosition: FlushbarPosition.TOP,
                  title: 'Hey !',
                  message: 'Your KYC Profile is pending to be filled.',
                  duration: Duration(seconds: 3),
                ).show(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: IconButton(
              visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: Icon(Icons.settings, size: 25, color: appBarIconColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              icon: Icon(
                Icons.logout_sharp,
                size: 25,
                color: appBarIconColor,
              ),
            ),
          ),
        ],
        backgroundColor: appBarColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Container(
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/lankapay_logo2.jpg',
                    height: 80,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "KYC Form Data Share",
                  style: TextStyle(
                    fontSize: Responsive.isMobileSmall(context)
                        ? 24
                        : Responsive.isMobileMedium(context)
                            ? 25
                            : Responsive.isMobileLarge(context)
                                ? 28
                                : Responsive.isTabletPortrait(context)
                                    ? 35
                                    : 40,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  child: Text(
                    "Generate QR",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      // backgroundColor: Colors.teal,
                      backgroundColor: buttonColor,
                      minimumSize: Size(size.width * 0.7, 60)),
                ),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      border: Border.all(
                          color: primaryBlue.withOpacity(0.1), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.05),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.qr_code_2_outlined,
                      size: 150,
                      color: Colors.grey,
                    )),
                SizedBox(height: 10),
                ElevatedButton(
                  child: Text(
                    "Download KYC Profile",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: buttonColor,
                      minimumSize: Size(size.width * 0.7, 60)),
                ),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      border: Border.all(
                          color: primaryBlue.withOpacity(0.1), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.05),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.file_download,
                      size: 150,
                      color: Colors.grey,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
