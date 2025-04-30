import 'package:another_flushbar/flushbar.dart';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';
import 'package:lankapay_shared_kyc/screens/settings/settings.dart';

class KYCProfileScreen extends StatefulWidget {
  KYCProfileScreen({Key? key}) : super(key: key);

  @override
  State<KYCProfileScreen> createState() => _KYCProfileScreenState();
}

class _KYCProfileScreenState extends State<KYCProfileScreen> {
  final int notificationCount = 1;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: appBarColor,
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
        title: Text(
          "KYC Profile",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: pageHeadingColor2),
        ),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
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
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    // Profile Picture
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          "https://pics.craiyon.com/2023-11-26/oMNPpACzTtO5OVERUZwh3Q.webp",
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // User Information
                    Center(
                      child: Text(
                        'John Fernando',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        'jf@gmail.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    // KYC Verified Information
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    SizedBox(height: 12),
                    InfoRow(label: 'Full Name', value: 'John Fernando'),
                    InfoRow(label: 'Date of Birth', value: '1990-01-01'),
                    InfoRow(label: 'Gender', value: 'Male'),
                    InfoRow(label: 'Phone (Mobile)', value: '+94 71 567 8490'),
                    InfoRow(label: 'Phone (Home)', value: '+94 34 226 7656'),
                    InfoRow(label: 'Email (Official)', value: 'jf@example.com'),
                    InfoRow(label: 'Email (Personal)', value: 'jf@gmail.com'),
                    SizedBox(height: 24),
                    Text(
                      'Address Information',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue),
                    ),
                    SizedBox(height: 12),
                    InfoRow(label: 'Address', value: '418/7, Main Street'),
                    InfoRow(label: 'City', value: 'Colombo 07'),
                    InfoRow(label: 'State', value: 'Western'),
                    InfoRow(label: 'Postal Code', value: '15600'),
                    InfoRow(label: 'Country', value: 'Sri Lanka'),
                    SizedBox(height: 24),
                    Text(
                      'Identification',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue),
                    ),
                    SizedBox(height: 12),
                    InfoRow(label: 'ID Type', value: 'NIC'),
                    InfoRow(label: 'ID Number', value: '1234-5678-9012'),
                    InfoRow(label: 'KYC Status', value: 'Verified'),
                    SizedBox(height: 10),

                    SizedBox(height: 20),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FilledButton.icon(
          onPressed: () {},
          icon: Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            "Edit Profile",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          iconAlignment: IconAlignment.end,
          style: FilledButton.styleFrom(
              backgroundColor: Colors.blue[900],
              minimumSize: Size(size.width, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
        ),
      ),
    );
  }
}

// Reusable Row for Displaying Information
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  InfoRow({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: primaryBlue,
            ),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
                color: primaryBlue),
          ),
        ],
      ),
    );
  }
}
