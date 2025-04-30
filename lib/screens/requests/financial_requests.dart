import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lankapay_shared_kyc/constants/responsive.dart';
import 'package:lankapay_shared_kyc/screens/kyc-form/edit_kyc_form.dart';
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import '../Settings/settings.dart';
import 'package:jiffy/jiffy.dart';

class FinacialInstituteRequest extends StatefulWidget {
  FinacialInstituteRequest({super.key});

  @override
  State<FinacialInstituteRequest> createState() =>
      _FinacialInstituteRequestState();
}

class _FinacialInstituteRequestState extends State<FinacialInstituteRequest> {
  List<Map<String, dynamic>> editRequests = [];
  late SharedPreferences _storage;
  String? token = "";
  final int notificationCount = 1;

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getSharedPrefs() async {
    _storage = await SharedPreferences.getInstance();
    token = _storage.getString('token')!;

    setState(() {
      loadAllRequests();
    });
  }

  Future<void> loadAllRequests() async {
    try {
      // Load JSON from assets
      final String jsonString =
          await rootBundle.loadString('assets/json/institute_requests.json');
      final Map<String, dynamic> jsonData =
          json.decode(jsonString); // Decode JSON as a map

      setState(() {
        // Extract the "editRequests" array
        editRequests =
            List<Map<String, dynamic>>.from(jsonData['editRequests']);
      });
    } catch (error) {
      print('Error loading JSON: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      // backgroundColor: appBackgroundColor2,
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
        elevation: 5,
        centerTitle: true,
        backgroundColor: appBarColor,
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
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: IconButton(
              visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
                );
              },
              icon: Icon(Icons.settings, size: 25, color: appBarIconColor),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
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
      ),
      body: Container(
        width: size.width,
        height: size.height,
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: NetworkImage(
        //         "https://i.pinimg.com/736x/91/ea/b7/91eab724c3f7ac487a6f54d4dec7d685.jpg"),
        //     fit: BoxFit.cover,
        //     opacity: 0.2,
        //   ),
        // ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: [
                // Logo
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2),
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
                  "KYC Form Edit Requests",
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
                SizedBox(height: 10),
                Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: ListView.builder(
                      itemCount: editRequests.length,
                      itemBuilder: (context, index) {
                        final request = editRequests[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditKYCForm(),
                                ),
                              );
                            },
                            child: Container(
                              // decoration: BoxDecoration(
                              //   color: Colors.white12,
                              //   borderRadius: BorderRadius.circular(10),
                              //   border: Border.all(
                              //     color: Colors.white70,
                              //     width: 1.5,
                              //   ),
                              // ),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: primaryBlue.withOpacity(0.1),
                                    width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryBlue.withOpacity(0.05),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12.0),
                                title: Text(
                                  '${request["id"]}) ${request["title"]}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Text(
                                      request["description"],
                                      style: TextStyle(color: primaryBlue),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      Jiffy.parse(
                                              DateTime.parse(request["date"])
                                                  .toString())
                                          .format(pattern: 'dd/MM/yyyy'),
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: primaryBlue),
                                    ),
                                  ],
                                ),
                                // trailing:Icon(Icons.remove_red_eye,
                                //     color: Colors.black54),
                              ),
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
