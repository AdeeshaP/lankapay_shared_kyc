import 'package:badges/badges.dart' as badges;
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lankapay_shared_kyc/api-services/api_access.dart';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:lankapay_shared_kyc/screens/allowed-institutes/allowed_institutes.dart';
import 'package:lankapay_shared_kyc/screens/home/login_modal_bottomsheet.dart';
import 'package:lankapay_shared_kyc/screens/kyc-form/kyc_form_wizrd.dart';
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';
import 'package:lankapay_shared_kyc/screens/profile/profile_kyc.dart';
import 'package:lankapay_shared_kyc/screens/profile/user_profile.dart';
import 'package:lankapay_shared_kyc/screens/requests/financial_requests.dart';
import 'package:lankapay_shared_kyc/screens/settings/settings.dart';
import 'package:lankapay_shared_kyc/screens/share-kyc/kyc_share_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.email});

  final String email;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  late SharedPreferences _storage;
  String? token = "";
  final String KEY_USERNAME = "KEY_USERNAME";
  final String KEY_PASSWORD = "KEY_PASSWORD";
  final String KEY_LOCAL_AUTH_ENABLED = "KEY_LOCAL_AUTH_ENABLED";
  final String REQUIRE_BIOMETRIC_LOGIN_SELECT_YES =
      "REQUIRE_BIOMETRIC_LOGIN_SELECT_YES";
  var localAuth = LocalAuthentication();
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

  // Retrieve token from secure storage

  Future<void> getSharedPrefs() async {
    _storage = await SharedPreferences.getInstance();
    token = _storage.getString('token')!;

    setState(() {
      fetchDetails();
    });

    Future.delayed(Duration(seconds: 2), () {
      _requestFingerprintAuthentication();
    });
  }

  Future<void> fetchDetails() async {
    var details = await ApiService.getDetailsOfSubmission(token!);
    if (details != null) {
      print("Details: $details");
    } else {
      print("Failed to fetch details.");
    }
  }

  _requestFingerprintAuthentication() async {
    String yesOrNo =
        await _secureStorage.read(key: "REQUIRE_BIOMETRIC_LOGIN_SELECT_YES") ??
            "false";

    if (await localAuth.canCheckBiometrics) {
      if (yesOrNo == "false") {
        await showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return EnableLocalAuthModalBottomSheet(action: _onEnableLocalAuth);
          },
        );
      }
    }
  }

  void _onEnableLocalAuth() async {
    await _secureStorage.write(key: KEY_LOCAL_AUTH_ENABLED, value: "true");
    await _secureStorage.write(
        key: REQUIRE_BIOMETRIC_LOGIN_SELECT_YES, value: "true");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        elevation: 2,
        // backgroundColor: primaryBlue,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Dashboard",
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: pageHeadingColor2),
        ),
        backgroundColor: appBarColor,
        actions: <Widget>[
          badges.Badge(
            position: badges.BadgePosition.custom(top: 0, start: 25),
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
          IconButton(
            visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
            icon: Icon(Icons.settings_outlined, color: appBarIconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: appBarIconColor),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
            SizedBox(height: 24),
            // Grid of options
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildDashboardItem(
                    'KYC Form',
                    Icons.description_outlined,
                    KYCFormWizard(personalEmail: widget.email),
                  ),
                  _buildDashboardItem(
                    'Share KYC Profile',
                    Icons.share_outlined,
                    KYCShareScreen(),
                  ),
                  _buildDashboardItem(
                    'Allowed Financial Institutions',
                    Icons.account_balance_outlined,
                    AllowedFinancialInstitutes(),
                  ),
                  _buildDashboardItem(
                    'Financial Institute Requests',
                    Icons.request_quote_outlined,
                    FinacialInstituteRequest(),
                  ),
                  _buildDashboardItem(
                    'KYC Profile',
                    Icons.badge_outlined,
                    KYCProfileScreen(),
                  ),
                  _buildDashboardItem(
                    'User Profile',
                    Icons.person_outline,
                    ProfileScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => screen,
          ),
        );
      },
      child: Container(
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => screen,
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 40,
                    color: primaryBlue,
                  ),
                  SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
