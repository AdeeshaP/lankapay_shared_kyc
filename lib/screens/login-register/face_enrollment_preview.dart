import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:lankapay_shared_kyc/api-services/api_access.dart';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';
import 'package:lankapay_shared_kyc/utils/dialogs.dart';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FaceEnrollmentPreviewScreen extends StatefulWidget {
  final String imagePath;
  final String fname;
  final String lname;
  final String pword;
  final String email;

  const FaceEnrollmentPreviewScreen({
    Key? key,
    required this.imagePath,
    required this.fname,
    required this.lname,
    required this.pword,
    required this.email,
  }) : super(key: key);

  @override
  State<FaceEnrollmentPreviewScreen> createState() =>
      _FaceEnrollmentPreviewScreenState();
}

class _FaceEnrollmentPreviewScreenState
    extends State<FaceEnrollmentPreviewScreen> {
  String locationAddress = "";
  String profileBase64 = "";
  String fileName = "";
  String fileMimeType = "";

  Future<void> _userRegsitration() async {
    // showProgressDialog(context);

    File file = File(widget.imagePath);
    List<int> fileBytes = await file.readAsBytes();

    var random = Random.secure();
    int randomInt = random.nextInt(1000);
    fileName = 'profile_${widget.fname}_${randomInt}.jpg';

    profileBase64 = base64Encode(fileBytes);
    fileMimeType = lookupMimeType(widget.imagePath)!;

    print(json.encode({
      "email": widget.email,
      "password": widget.pword,
      "firstName": widget.fname,
      "lastName": widget.lname,
      "profilePicture": {
        "fileName": fileName,
        "fileMimeType": fileMimeType,
        "fileBase64": profileBase64,
      },
    }));

    final request = await ApiService.registerUser(widget.email, widget.pword,
        widget.fname, widget.lname, fileName, fileMimeType, profileBase64);

    if (request != null) {
      print("request.statusCode ${request.statusCode}");
      if (request.statusCode == 200) {
        // final responseBody = jsonDecode(request.body);
        _showConfirmationDialog(context);
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Sign Up Failed"),
            content: Text("Please check your credentials."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } else {
      showWarningDialogPopup(
        context,
        Icons.warning,
        "Sign Up Failed.!! \nSystem Error.",
        okRecognition,
      );
    }
  }

  void okRecognition() {
    closeDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    // Get current date and time
    Size size = MediaQuery.of(context).size;

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('MMMM dd, yyyy').format(now);
    final String formattedTime = DateFormat('hh:mm a').format(now);

    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appBarIconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Face Enrollment Preview',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg1.png"),
              fit: BoxFit.cover,
              opacity: 0.7,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Captured Image
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),

                // User Details
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white54, width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Name
                        _buildDetailRow(
                          icon: Icons.person,
                          label: 'Name',
                          value: widget.fname + " " + widget.lname,
                        ),

                        // Email
                        _buildDetailRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: widget.email,
                        ),

                        // Date and Time
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value: formattedDate,
                        ),
                        _buildDetailRow(
                          icon: Icons.access_time,
                          label: 'Time',
                          value: formattedTime,
                        ),
                      ],
                    ),
                  ),
                ),

                // Confirm Button
                Container(
                  width: double.infinity,
                  height: 60,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      _userRegsitration();
                      // _showConfirmationDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Confirm Enrollment',
                      style: TextStyle(
                        color: actionBtnTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build consistent detail rows
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Confirmation Dialog
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: appBackgroundColor,
          titlePadding: EdgeInsets.only(top: 20, bottom: 10, right: 5, left: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Column(
            children: [
              Text(
                "Success!",
                style: TextStyle(
                    fontSize: 25,
                    color: successPopupheading,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Image.asset(
                "assets/images/success-green-icon.png",
                height: 60,
                width: 80,
              ),
            ],
          ),
          content: Text(
            'Your profile registration is successful. Please proceed to create your KYC profile. ',
            style: TextStyle(
              fontSize: 19,
              color: normalTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          // content: Text(
          //   'Are you sure you want to confirm your face enrollment?',
          //   textAlign: TextAlign.center,
          // ),
          actions: [
            ElevatedButton(
              child: Text(
                'OK',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
