import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lankapay_shared_kyc/screens/login-register/face_enrollment_preview.dart';

class FaceEnrollmentScreen extends StatefulWidget {
  const FaceEnrollmentScreen({
    super.key,
    required this.fName,
    required this.lName,
    required this.email,
    required this.password,
  });

  final String fName;
  final String lName;
  final String email;
  final String password;

  @override
  _FaceEnrollmentScreenState createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras!.isNotEmpty) {
        // Initialize the first camera
        _cameraController = CameraController(
            _cameras![_selectedCameraIndex], ResolutionPreset.high);

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _switchCamera() {
    if (_cameras != null && _cameras!.length > 1) {
      // Cycle through available cameras
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      _initializeCamera();
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        // Capture the image
        final XFile image = await _cameraController!.takePicture();

        print('Image captured: ${image.path}');

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FaceEnrollmentPreviewScreen(
              imagePath: image.path,
              fname: widget.fName,
              lname: widget.lName,
              email: widget.email,
              pword: widget.password,
            ),
          ),
        );

        // Optional: Navigate to next screen or process the image
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (context) => ImagePreviewScreen(imagePath: image.path)
        // ));
      } catch (e) {
        print('Error capturing image: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 198, 218, 248),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.help_center_rounded,
                size: 35,
                color: Colors.black,
              ),
            ),
          ),
        ],
        title: Text(
          'Face Enrollment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // App Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset(
                // 'assets/images/lankapay_logo-removebg.png',
                'assets/images/lankapay_logo.jpg',
                height: 80,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),

            // Camera Preview
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _isCameraInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          // Camera Preview
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: AspectRatio(
                              aspectRatio: 3 / 4, // Adjust as needed
                              child: CameraPreview(_cameraController!),
                            ),
                          ),

                          // Face Enrollment Overlay
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Opacity(
                                opacity: 0.3,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Camera Switch Button
                  IconButton(
                    icon: Icon(Icons.flip_camera_ios,
                        color: Colors.white, size: 40),
                    onPressed: _switchCamera,
                  ),

                  const SizedBox(width: 40),

                  // Capture Button
                  ElevatedButton(
                    onPressed: _captureImage,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                      backgroundColor: Colors.white,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 40,
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
        