import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';
import 'package:another_flushbar/flushbar.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false; // Theme toggle
  bool isNotificationsEnabled = true; // Notifications toggle
  String selectedLanguage = 'English'; // Default language
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
        title: Text(
          'Settings',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w500, color: appBarIconColor),
        ),
        centerTitle: true,
        actions: <Widget>[
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 6),
            badgeContent: Text(
              notificationCount > 99 ? '99+' : '$notificationCount',
              style: TextStyle(color: primaryBlue, fontSize: 12),
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
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
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
        child: ListView(
          children: [
            // Theme Toggle
            ListTile(
              leading: Icon(
                Icons.brightness_6,
                color: primaryBlue,
              ),
              title: Text('Dark Mode',
                  style: TextStyle(
                    color: primaryBlue,
                  )),
              trailing: Switch(
                activeColor: primaryBlue,
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                    // Dynamically toggle between themes
                    isDarkMode
                        ? Theme.of(context)
                            .copyWith(brightness: Brightness.dark)
                        : Theme.of(context)
                            .copyWith(brightness: Brightness.light);
                  });
                  // Change app theme dynamically (if needed)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Theme changed to ${isDarkMode ? "Dark" : "Light"}'),
                    ),
                  );
                },
              ),
            ),
            Divider(),

            // Notifications Toggle
            // ListTile(
            //   leading: Icon(Icons.notifications),
            //   title: Text('Enable Notifications'),
            //   trailing: Switch(
            //     value: isNotificationsEnabled,
            //     onChanged: (value) {
            //       setState(() {
            //         isNotificationsEnabled = value;
            //       });
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text(
            //               'Notifications ${isNotificationsEnabled ? "enabled" : "disabled"}'),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            // Divider(),

            // Language Selection
            ListTile(
              leading: Icon(
                Icons.language,
                color: primaryBlue,
              ),
              title: Text('App Language',
                  style: TextStyle(
                    color: primaryBlue,
                  )),
              subtitle: Text(selectedLanguage,
                  style: TextStyle(
                    color: primaryBlue,
                  )),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: primaryBlue,
              ),
              onTap: () {
                _showLanguageDialog();
              },
            ),
            Divider(),

            // Other Settings Placeholder
            ListTile(
              leading: Icon(
                Icons.security,
                color: primaryBlue,
              ),
              title: Text('Privacy Settings',
                  style: TextStyle(
                    color: primaryBlue,
                  )),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: primaryBlue,
              ),
              onTap: () {
                // Navigate to Privacy Settings (Add your logic here)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Privacy Settings clicked')),
                );
              },
            ),
            Divider(),

            ListTile(
              leading: Icon(
                Icons.info,
                color: primaryBlue,
              ),
              title: Text('About App',
                  style: TextStyle(
                    color: primaryBlue,
                  )),
              trailing: Icon(Icons.arrow_forward_ios, color: primaryBlue),
              onTap: () {
                // Navigate to About App (Add your logic here)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('About App clicked')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show Dialog for Language Selection
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: SingleChildScrollView(
            child: Column(
              children: ['English', 'Spanish', 'French', 'German']
                  .map(
                    (language) => RadioListTile(
                      title: Text(language),
                      value: language,
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value!;
                        });
                        Navigator.pop(context); // Close the dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Language changed to $value')),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
