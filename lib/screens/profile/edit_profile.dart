import 'package:another_flushbar/flushbar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:lankapay_shared_kyc/constants/responsive.dart';
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';
import 'package:lankapay_shared_kyc/screens/profile/user_profile.dart';

import '../settings/settings.dart';

class UserEditProfile extends StatefulWidget {
  const UserEditProfile({Key? key}) : super(key: key);

  @override
  State<UserEditProfile> createState() => _UserEditProfileState();
}

class _UserEditProfileState extends State<UserEditProfile> {
  final int notificationCount = 1;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        automaticallyImplyLeading: true,
        elevation: 5,
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color.fromARGB(255, 243, 241, 241),
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
                Icons.notifications,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () async {
                await Flushbar(
                  backgroundColor: Colors.blue[900]!,
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
                );
              },
              icon: Icon(
                Icons.settings,
                size: 30,
                color: Color.fromARGB(255, 6, 55, 128),
              ),
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
                color: Color.fromARGB(255, 6, 55, 128),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container(
            //   child: Align(
            //     alignment: Alignment.center,
            //     child: Text(
            //       "My Profile",
            //       style: TextStyle(
            //         fontSize: Responsive.isMobileSmall(context) ||
            //                 Responsive.isMobileMedium(context) ||
            //                 Responsive.isMobileLarge(context)
            //             ? size.width * 0.065
            //             : Responsive.isTabletPortrait(context)
            //                 ? 30
            //                 : 34,
            //         fontWeight: FontWeight.w700,
            //         color: Colors.black,
            //       ),
            //       textAlign: TextAlign.center,
            //     ),
            //   ),
            // ),
            Container(
              height: size.height * 0.9,
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    color: Colors.blue[900],
                    // color: Colors.teal,
                    child: Column(
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                  radius: Responsive.isMobileSmall(context)
                                      ? 40
                                      : Responsive.isMobileMedium(context) ||
                                              Responsive.isMobileLarge(context)
                                          ? size.width * 0.16
                                          : Responsive.isTabletPortrait(context)
                                              ? size.width * 0.09
                                              : size.width * 0.08,
                                  backgroundColor: actionBtnTextColor,
                                  // --------- User Profile Picture ---------- //
                                  child: Container(
                                    height: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? size.width * 0.3
                                        : Responsive.isTabletPortrait(context)
                                            ? size.width * 0.17
                                            : size.width * 0.15,
                                    width: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? size.width * 0.3
                                        : Responsive.isTabletPortrait(context)
                                            ? size.width * 0.17
                                            : size.width * 0.15,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                                      ),
                                    ),
                                  )), // Camera Icon
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    // Add your action for updating the profile picture
                                    print('Camera icon tapped!');
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Kamal Perera",
                          style: TextStyle(
                            fontSize: Responsive.isMobileSmall(context) ||
                                    Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.065
                                : Responsive.isTabletPortrait(context)
                                    ? 30
                                    : 34,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      children: [
                        //  Padding(
                        //   padding: EdgeInsets.only(
                        //       top: 10, bottom: 5, left: 8, right: 8),
                        //   child: Align(
                        //     alignment: Alignment.topLeft,
                        //     child: Text(
                        //       'Personal Info',
                        //       style: TextStyle(
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                          child: Column(
                            children: [
                              TextFormField(
                                style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 14
                                      : Responsive.isMobileMedium(context)
                                          ? 15
                                          : Responsive.isMobileLarge(context)
                                              ? 17
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Username",
                                  labelStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? size.width * 0.042
                                        : Responsive.isMobileMedium(context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? size.width * 0.04
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? size.width * 0.02
                                                : size.width * 0.04,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 14
                                      : Responsive.isMobileMedium(context)
                                          ? 15
                                          : Responsive.isMobileLarge(context)
                                              ? 17
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Official Email",
                                  labelStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? size.width * 0.042
                                        : Responsive.isMobileMedium(context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? size.width * 0.04
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? size.width * 0.02
                                                : size.width * 0.04,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: "adeesah@gmail.com",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 14
                                      : Responsive.isMobileMedium(context)
                                          ? 15
                                          : Responsive.isMobileLarge(context)
                                              ? 17
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Personal Email",
                                  labelStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? size.width * 0.042
                                        : Responsive.isMobileMedium(context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? size.width * 0.04
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? size.width * 0.02
                                                : size.width * 0.04,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: "adeesah@gmail.com",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 14
                                      : Responsive.isMobileMedium(context)
                                          ? 15
                                          : Responsive.isMobileLarge(context)
                                              ? 17
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Phone (Mobile)",
                                  labelStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? size.width * 0.042
                                        : Responsive.isMobileMedium(context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? size.width * 0.04
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? size.width * 0.02
                                                : size.width * 0.04,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 14
                                      : Responsive.isMobileMedium(context)
                                          ? 15
                                          : Responsive.isMobileLarge(context)
                                              ? 17
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Residential Address",
                                  labelStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? size.width * 0.042
                                        : Responsive.isMobileMedium(context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? size.width * 0.04
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? size.width * 0.02
                                                : size.width * 0.04,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: "adeesah@gmail.com",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                style: TextStyle(
                                  fontSize: Responsive.isMobileSmall(context)
                                      ? 14
                                      : Responsive.isMobileMedium(context)
                                          ? 15
                                          : Responsive.isMobileLarge(context)
                                              ? 17
                                              : Responsive.isTabletPortrait(
                                                      context)
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Personal Address",
                                  labelStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: Responsive.isMobileSmall(context)
                                        ? size.width * 0.042
                                        : Responsive.isMobileMedium(context) ||
                                                Responsive.isMobileLarge(
                                                    context)
                                            ? size.width * 0.04
                                            : Responsive.isTabletPortrait(
                                                    context)
                                                ? size.width * 0.02
                                                : size.width * 0.04,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: "adeesah@gmail.com",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      iconAlignment: IconAlignment.end,
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Colors.blue[900],
                        ),
                        minimumSize: WidgetStatePropertyAll(Size(140, 45)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
