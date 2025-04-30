import 'dart:convert';
import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:lankapay_shared_kyc/api-services/api_access.dart';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String profileImageUrl =
      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
  late SharedPreferences _storage;

  var unController = TextEditingController();
  var mobileNoController = TextEditingController();
  var landNoController = TextEditingController();
  var emailContoller = TextEditingController();
  Map<String, dynamic>? profileDetails;
  Uint8List? imageBytes;
  String? token = "";
  String username = "";
  String profilepicbase64 = "";
  String email = "";
  final int notificationCount = 1;

  // Simulated user data
  final Map<String, String> userData = {
    'username': 'John Doe',
    'email': 'john.doe@example.com',
    'avatarUrl': '', // Add a valid avatar URL if available
    'nic': '',
    'address': '',
    'phoneNumber': '',
  };

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
      fetchProfileDetails();
    });
  }

  Future<void> fetchProfileDetails() async {
    var response = await ApiService.getProfileDetails(token!);

    if (response.statusCode == 200) {
      profileDetails = jsonDecode(response.body);

      if (profileDetails != null) {
        setState(() {
          username =
              profileDetails!['firstName'] + " " + profileDetails!['lastName'];
          email = profileDetails!['email'];
          String profilePic = profileDetails!['profilePic'] ?? '';

          print("profilePic is $profilePic");
          // Remove data URI prefix if present
          profilepicbase64 = profilePic.contains(',')
              ? profilePic.split(',').last
              : profilePic;

          try {
            imageBytes = base64.decode(profilepicbase64);
          } catch (e) {
            print('Error decoding base64 image: $e');
            imageBytes = null;
          }

          emailContoller.text = email;
          unController.text = username;
        });

        print("username is $username");
        print("profilepicbase64 is $profilepicbase64");

        emailContoller = TextEditingController(text: email);
        unController = TextEditingController(text: username);
      } else {
        print("Failed to fetch details.");
      }
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
        title: Text(
          "Profile",
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: pageHeadingColor2),
        ),
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
              onPressed: () {},
              icon: Icon(
                Icons.settings,
                size: 25,
                color: appBarIconColor,
              ),
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                // Profile Avatar and Details
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: primaryBlue.withOpacity(0.1), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.05),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryBlue,
                            width: 1,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.blue.shade50,
                          backgroundImage: imageBytes != null
                              ? MemoryImage(imageBytes!)
                              : NetworkImage(profileImageUrl),
                          // child: profilepicbase64 == ""
                          //     ? Text(
                          //         username![0].toUpperCase(),
                          //         style: TextStyle(
                          //           fontSize: 48,
                          //           color: Colors.blue.shade800,
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       )
                          //     : null,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Username
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Email
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Personal Details Section
                _buildDetailSection(),

                SizedBox(height: 20),

                // Update Profile Button
                Center(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.edit,
                      size: 25,
                      color: Colors.white,
                    ),
                    onPressed: _navigateToUpdateProfile,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        minimumSize: Size(double.infinity, 40)),
                    label: Text(
                      'Update Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: actionButtonTextColor,
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

  Widget _buildDetailSection() {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            SizedBox(height: 16),

            // Divider
            Divider(color: Colors.grey.shade300),
            SizedBox(height: 8),

            // Details Rows with Icons
            _buildDetailRowWithIcon(
              Icons.credit_card,
              'NIC',
              userData['nic'] == "" ? 'Not Added' : userData['nic']!,
            ),

            _buildDetailRowWithIcon(
              Icons.location_on,
              'Address',
              userData['address'] == "" ? 'Not Added' : userData['address']!,
              maxLines: 2,
            ),

            _buildDetailRowWithIcon(
              Icons.phone,
              'Phone Number',
              userData['phoneNumber'] == ""
                  ? 'Not Added'
                  : userData['phoneNumber']!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRowWithIcon(IconData icon, String label, String value,
      {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            // color: Colors.blue.shade600,
            color: primaryBlue,
            size: 24,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    // color: Colors.black87,
                    color: primaryBlue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    color: value.isEmpty ? Colors.red : primaryBlue,
                    fontStyle:
                        value.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUpdateProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProfileScreen(
          fname: profileDetails!['firstName'],
          lname: profileDetails!['lastName'],
          email: profileDetails!['email'],
        ),
      ),
    );
  }
}

// The UpdateProfileScreen remains the same as in the previous implementation
class UpdateProfileScreen extends StatefulWidget {
  final String fname;
  final String lname;
  final String email;

  UpdateProfileScreen(
      {Key? key, required this.fname, required this.lname, required this.email})
      : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late TextEditingController _nicController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _fnameController;
  late TextEditingController _lnameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _nicController = TextEditingController(text: "");
    _phoneNumberController = TextEditingController(text: "");
    _addressController = TextEditingController(text: "");
    _emailController = TextEditingController(text: widget.email);
    _fnameController = TextEditingController(text: widget.fname);
    _lnameController = TextEditingController(text: widget.lname);
  }

  @override
  void dispose() {
    _nicController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 198, 218, 248),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Update Profile',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.settings,
                size: 30,
                color: Color.fromARGB(255, 6, 55, 128),
              ),
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
                color: Color.fromARGB(255, 6, 55, 128),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              controller: _fnameController,
              label: 'First Name',
              icon: Icons.person,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _lnameController,
              label: 'Last Name',
              icon: Icons.person,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _nicController,
              label: 'NIC',
              icon: Icons.location_on,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.location_on,
              maxLines: 3,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _phoneNumberController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                minimumSize: Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: Text(
                'Save Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: actionButtonTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.blue.shade600),
      ),
    );
  }

  void _saveProfile() {
    // Create updated data map
    final updatedData = {
      'nic': _nicController.text,
      'address': _addressController.text,
      'phoneNumber': _phoneNumberController.text,
    };

    print(updatedData);

    // Call the update callback

    // Navigate back to profile screen
    Navigator.pop(context);
  }
}
