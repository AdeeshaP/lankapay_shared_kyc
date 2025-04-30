import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:badges/badges.dart' as badges;
import 'package:lankapay_shared_kyc/api-services/api_access.dart';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:lankapay_shared_kyc/constants/responsive.dart';
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';
import 'package:lankapay_shared_kyc/screens/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/dialogs.dart';

class AllowedFinancialInstitutes extends StatefulWidget {
  const AllowedFinancialInstitutes({super.key});

  @override
  State<AllowedFinancialInstitutes> createState() =>
      _AllowedFinancialInstitutesState();
}

class _AllowedFinancialInstitutesState
    extends State<AllowedFinancialInstitutes> {
  bool isAllowedSelected = true;
  List<Map<String, dynamic>> allowedBanks = []; // List to hold bank ID and name
  List<Map<String, dynamic>> notAllowedBanks = [];
  late SharedPreferences _storage;
  final int notificationCount = 1;
  String token = "";
  String kycProfileId = "";
  int bankId = 0;
  bool isLoading = true;

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

    print("token is $token");

    await fetchAllowedBanks();
    await fetchNotAllowedBanks();
  }


  Future<void> submitChangeRequest(int _bankid) async {
    print("kyc profile is $kycProfileId");
    print("bankId is $_bankid");
    _storage = await SharedPreferences.getInstance();
    final request =
        await ApiService.changeAllowedRequest(token, kycProfileId, _bankid);

    if (request != null) {
      if (request.statusCode == 200) {
        // final responseBody = jsonDecode(request.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllowedFinancialInstitutes(),
          ),
        );
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

  void okRecognition() {
    closeDialog(context);
  }

  Future<void> fetchAllowedBanks() async {
    try {
      var response = await ApiService.getAllowedNotAllowedBanks(token, true);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract 'banks' list
        List banks = responseData['banks'];
        kycProfileId = responseData['kycProfileId'];

        // Map the bank names (firstName + lastName)
        List<Map<String, dynamic>> bankDetails = banks.map((bank) {
          return {
            'id': bank['id'],
            'name':
                '${bank['firstName'] ?? ''} ${bank['lastName'] ?? ''}'.trim(),
          };
        }).toList();

        // Update the state
        setState(() {
          allowedBanks = bankDetails;
          isLoading = false; // Loading complete
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      isLoading = false; // Loading complete
    }
  }

  Future<void> fetchNotAllowedBanks() async {
    try {
      var response = await ApiService.getAllowedNotAllowedBanks(token, false);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract 'banks' list
        List banks = responseData['banks'];

        List<Map<String, dynamic>> bankDetails = banks.map((bank) {
          return {
            'id': bank['id'],
            'name':
                '${bank['firstName'] ?? ''} ${bank['lastName'] ?? ''}'.trim(),
          };
        }).toList();

        setState(() {
          notAllowedBanks = bankDetails;
          isLoading = false; // Loading complete
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      isLoading = false; // Loading complete
    }
  }

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
        elevation: 2,
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
                Icons.notifications,
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
      ),
      body: Container(
        width: size.width,
        height: size.height,
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: NetworkImage(
        //         "https://i.pinimg.com/736x/91/ea/b7/91eab724c3f7ac487a6f54d4dec7d685.jpg"),
        //     fit: BoxFit.cover,
        //     opacity: 0.3,
        //   ),
        // ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: // Logo
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
            ),
            Text(
              "KYC Profile Access",
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
            SizedBox(height: 20),
            ToggleButtons(
              isSelected: [isAllowedSelected, !isAllowedSelected],
              onPressed: (index) {
                setState(() {
                  isAllowedSelected = index == 0;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    'Allowed',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    'Not Allowed',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
              // color: Colors.black,
              color: Colors.grey,
              selectedColor: actionButtonTextColor,
              // fillColor: Colors.teal,
              fillColor: buttonColor,
              borderColor: Colors.grey,
            ),
            SizedBox(height: 20),
            Expanded(
              child:isLoading
                  ? Center(child: CircularProgressIndicator())
                  : allowedBanks.isEmpty && isAllowedSelected
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 20),
                            Text(
                              "No allowed banks or financial institutes.",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : isLoading
                          ? Center(child: CircularProgressIndicator())
                          : notAllowedBanks.isEmpty && !isAllowedSelected
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_balance,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    Text(
                                      "No available not allowed institutes or banks",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 25),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  itemCount: isAllowedSelected
                                      ? allowedBanks.length
                                      : notAllowedBanks.length,
                                  itemBuilder: (context, index) {
                                    final icon = isAllowedSelected
                                        ? Icons
                                            .lock // Unlock icon for "Allowed"
                                        : Icons
                                            .lock_open; // Lock icon for "Not Allowed"

                                    String bankName = isAllowedSelected
                                        ? allowedBanks[index]['name']
                                        : notAllowedBanks[index]['name'];
                                    int bankId = isAllowedSelected
                                        ? allowedBanks[index]['id']
                                        : notAllowedBanks[index]['id'];

                                    return ListTile(
                                      title: Text(
                                        bankName,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 17),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(icon, color: Colors.white),
                                        onPressed: () {
                                          _showConfirmationDialog(bankName,
                                              isAllowedSelected, bankId);
                                        },
                                      ),
                                      leading: Icon(
                                        Icons.business,
                                        // color: buttonColor,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showConfirmationDialog(String name, bool isAllowed) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(0.0),
  //         ),
  //         title: Text(
  //           "Please Confirm",
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         content: Text(
  //           isAllowed
  //               ? "Do you want to block access to $name?"
  //               : "Do you want to allow access to $name?",
  //           style: TextStyle(fontSize: 16),
  //           textAlign: TextAlign.justify,
  //         ),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context); // Close the dialog
  //             },
  //             style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.grey, // Submit button color
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(0.0),
  //                 ),
  //                 minimumSize: Size(90, 40)),
  //             child: Text(
  //               "Cancel",
  //               style: TextStyle(color: actionButtonTextColor),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               submitChangeRequest(bankId);
  //               Navigator.pop(context); // Close the dialog
  //             },
  //             style: ElevatedButton.styleFrom(
  //                 backgroundColor: buttonColor, // Submit button color
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(0.0),
  //                 ),
  //                 minimumSize: Size(90, 40)),
  //             child: Text(
  //               "OK",
  //               style: TextStyle(color: actionButtonTextColor),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showConfirmationDialog(String name, bool isAllowed, int bankId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          title: Text(
            "Please Confirm",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            isAllowed
                ? "Do you want to block access to $name?"
                : "Do you want to allow access to $name?",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, // Submit button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  minimumSize: Size(90, 40)),
              child: Text(
                "Cancel",
                style: TextStyle(color: actionButtonTextColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform block/unblock action here
                submitChangeRequest(bankId);
                Navigator.pop(context); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor, // Submit button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  minimumSize: Size(90, 40)),
              child: Text(
                "OK",
                style: TextStyle(color: actionButtonTextColor),
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget _buildBankTile(String name, String type) {
  //   final icon = isAllowedSelected
  //       ? Icons.lock // Unlock icon for "Allowed"
  //       : Icons.lock_open; // Lock icon for "Not Allowed"

  //   return ListTile(
  //     leading: Icon(
  //       type == "Bank" ? Icons.business : Icons.account_balance,
  //       // color: buttonColor,
  //       color: primaryBlue,
  //     ),
  //     title: Text(
  //       name,
  //       style: TextStyle(color: primaryBlue),
  //     ),
  //     trailing: IconButton(
  //       icon: Icon(icon, color: primaryBlue),
  //       onPressed: () {
  //         // Show confirmation dialog
  //         _showConfirmationDialog(name, isAllowedSelected);
  //       },
  //     ),
  //     onTap: () {},
  //   );
  // }
}
