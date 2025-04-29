import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lankapay_shared_kyc/screens/login-register/landing_screen.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras = <CameraDescription>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  Map<Permission, PermissionStatus> permissions = await [
    Permission.camera,
    Permission.location,
  ].request();

  if ((permissions[Permission.camera] == PermissionStatus.granted ||
          permissions[Permission.camera] == PermissionStatus.restricted ||
          permissions[Permission.camera] ==
              PermissionStatus.permanentlyDenied) &&
      (permissions[Permission.location] == PermissionStatus.granted ||
          permissions[Permission.location] == PermissionStatus.restricted ||
          permissions[Permission.location] ==
              PermissionStatus.permanentlyDenied)) {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light, // Set default theme
      home: LandingScreen(),
    );
  }
}
