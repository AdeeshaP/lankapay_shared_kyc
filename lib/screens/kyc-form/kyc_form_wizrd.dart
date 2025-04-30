import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:another_flushbar/flushbar.dart';
import 'package:lankapay_shared_kyc/api-services/api_access.dart';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:im_stepper/stepper.dart';
import 'package:lankapay_shared_kyc/constants/responsive.dart';
import 'package:lankapay_shared_kyc/screens/home/home_screen.dart';
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';
import 'package:lankapay_shared_kyc/screens/settings/settings.dart';
import 'package:lankapay_shared_kyc/utils/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;

class KYCFormWizard extends StatefulWidget {
  KYCFormWizard({super.key, required this.personalEmail});

  final String personalEmail;

  @override
  State<KYCFormWizard> createState() => _KYCFormWizardState();
}

class _KYCFormWizardState extends State<KYCFormWizard> {
  TextEditingController idNumberController = new TextEditingController();
  TextEditingController titleController = new TextEditingController();
  TextEditingController idTypeController = new TextEditingController();
  TextEditingController name1Controller = new TextEditingController();
  TextEditingController name2Controller = new TextEditingController();
  TextEditingController name3Controller = new TextEditingController();
  TextEditingController dobController = new TextEditingController();
  TextEditingController pAddressController = new TextEditingController();
  TextEditingController texPayerNoController = new TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController landNumberController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController perosnlEmailController = TextEditingController();
  TextEditingController officalEmailController = new TextEditingController();
  TextEditingController businessNatureController = new TextEditingController();
  TextEditingController connectedBusinessController =
      new TextEditingController();
  TextEditingController pepInfoController = new TextEditingController();
  TextEditingController photoController = new TextEditingController();
  TextEditingController visaController = new TextEditingController();
  TextEditingController fundSourcesController = new TextEditingController();
  TextEditingController wealthSourcesController = new TextEditingController();
  TextEditingController incomeController = new TextEditingController();
  TextEditingController employerNameController = new TextEditingController();
  TextEditingController employerPhoneController = new TextEditingController();
  TextEditingController employerEmailController = new TextEditingController();
  TextEditingController employerAddressController = new TextEditingController();
  TextEditingController employerPositionController =
      new TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );
  String? _selectedType;
  File? imageFile;
  FilePickerResult? result;
  String attachedFileBase64String = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> idTypes = ['National ID', 'Passport', 'Driving License'];
  Uint8List? _signatureImage;
  Uint8List? _uploadedSignImage;
  String _signatureFileName = "";
  String _signatureBase64 = "";
  String _iDSaveName = "";
  String _uploadEmployeeDocumentation = "";
  String? _customerPhotoName;
  List<String> _pictures = [];
  String _picture = "";
  Uint8List? _customerPhoto;
  String idType = "";
  String idNumber = "";
  String taxpayerNumber = "";
  String postalCode = "";
  String permanentAddress = "";
  String residentialAddress = "";
  String city = "";
  String district = "";
  String stat = "";
  String employerName = "";
  String employerAddrss = "";
  String employerEmail = "";
  String employerPosition = "";
  String emloyerPhone = "";
  String dob = "";
  String nameWithInitials = "";
  String fullName = "";
  String otherNames = "";
  String officialEmail = "";
  String landlineNo = "";
  String mobileNo = "";
  String buisnesssNature = "";
  String connectedBusineses = "";
  String title = "";
  String TINnumber = "";
  String sourceOfFunds = "";
  String sourceOfWealth = "";
  double income = 0.0;
  String visaDate = "";
  Map<String, String> occupationDetails = {};
  List<Map<String, String>> fileList = [];
  String token = "";
  bool isLoading = true;
  int activeIndex = 0;
  int totalIndex = 8;
  late SharedPreferences _storage;
  final int notificationCount = 1;
  List<String> districts = [];
  String? selectedCountry;
  String? selectedProvince;
  String? selectedDistrict;
  bool isSriLankaSelected = false;
  bool isSameAsAbove = false;
  bool isFormAlradySubmitted = false;

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
    initPlatformState();
    perosnlEmailController = TextEditingController(text: widget.personalEmail);

    name1Controller.addListener(() {
      setState(() {
        name2Controller.text = _generateNameWithInitials(
          name1Controller.text,
        );
      });
    });
  }

  Future<void> getSharedPrefs() async {
    _storage = await SharedPreferences.getInstance();
    token = _storage.getString('token')!;

     setState(() {
      fetchDetails();
    });
  }

  Future<void> fetchDetails() async {
    try {
      final response = await ApiService.getDetailsOfSubmission(token);
      print("API Response: $response"); // Debugging: print the raw response
      print("Body: ${response.body}"); // Debugging: print the raw response

      if (response.body != "null") {
        setState(() {
          isFormAlradySubmitted = true;
          isLoading = false;
        });
      } else {
        print("API returned null. Check the server or request parameters.");
        setState(() {
          isLoading = false;
          isFormAlradySubmitted = false;
        });
      }
    } catch (e) {
      print("Error while fetching details: $e");
      setState(() {
        isLoading = false;
        isFormAlradySubmitted = false;
      });
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  final Map<String, bool> titles = {
    'Mr': false,
    'Mrs': false,
    'Miss': false,
    'Rev': false,
  };

  final List<String> countries = ['India', 'Sri Lanka', 'USA', 'Canada'];
  final List<String> provincesInSriLanka = [
    'Central',
    'Eastern',
    'Northern',
    'Southern',
    'Western',
    'North Western',
    'North Central',
    'Uva',
    'Sabaragamuwa'
  ];

  // Map ofs to districts
  final Map<String, List<String>> provinceToDistricts = {
    'Central': ['Kandy', 'Matale', 'Nuwara Eliya'],
    'Eastern': ['Ampara', 'Batticaloa', 'Trincomalee'],
    'Northern': ['Jaffna', 'Kilinochchi', 'Mannar', 'Mullaitivu', 'Vavuniya'],
    'Southern': ['Galle', 'Matara', 'Hambantota'],
    'Western': ['Colombo', 'Gampaha', 'Kalutara'],
    'North Western': ['Kurunegala', 'Puttalam'],
    'North Central': ['Anuradhapura', 'Polonnaruwa'],
    'Uva': ['Badulla', 'Moneragala'],
    'Sabaragamuwa': ['Ratnapura', 'Kegalle'],
  };

  String _generateNameWithInitials(String fullName) {
    if (fullName.isEmpty) return '';

    List<String> nameParts = fullName.trim().split(' ');
    if (nameParts.length == 1) {
      // Single name, no initials
      return nameParts[0];
    }

    String initials = nameParts
        .sublist(0, nameParts.length - 1) // Take all parts except the last name
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join('.');
    String lastName = nameParts.last;

    return '$initials. $lastName';
  }

  void okRecognition() {
    closeDialog(context);
  }

  void addFileToList({
    required String fileName,
    required String fileType,
    required String fileMimeType,
    required String base64Content,
  }) {
    fileList.add({
      "fileName": fileName,
      "fileType": fileType,
      "fileMimeType": fileMimeType,
      "fileBase64": base64Content,
    });
  }

  void scanDocuments() async {
    List<String> pictures;
    String pic;
    String fileName = "";
    String base64String = "";

    try {
      pictures = await CunningDocumentScanner.getPictures() ?? [];
      pic = pictures[0];
      var random = Random.secure();
      int randomInt = random.nextInt(1000);
      fileName = 'document_${idTypeController.text}_${randomInt}.jpg';

      // Create File object
      File file = File(pic);

      // Check file size
      int fileSizeInBytes = file.lengthSync(); // Returns size in bytes
      double fileSizeInKB = fileSizeInBytes / 1024; // Size in KB
      double fileSizeInMB = fileSizeInKB / 1024; // Size in MB

      print(
          "File size: $fileSizeInBytes bytes, $fileSizeInKB KB, $fileSizeInMB MB");

      var bytes = File(pic).readAsBytesSync();
      base64String = base64Encode(bytes);

      if (!mounted) return;
      setState(() {
        _pictures = pictures;
        _picture = pic;
        _iDSaveName = fileName;
      });
      print(_pictures);

      addFileToList(
        fileName: "document1.jpg",
        fileType: "id",
        fileMimeType: "image/jpeg",
        base64Content: "data:image/jpeg;base64,/" + base64String,
      );

      print("Base64 String: $base64String");
    } catch (exception) {
      // Handle exception here
    }
  }

  Future<void> attachEmployeeFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _uploadEmployeeDocumentation = result.files.single.name;
      });

      File file = File(result.files.single.path!);
      List<int> fileBytes = await file.readAsBytes();
      String base64String2 = base64Encode(fileBytes);
      String mimeType1 = lookupMimeType(file.path) ?? "";

      print("mime type 1 is $mimeType1");

      addFileToList(
        // fileName: result.files.single.name,
        fileName: "document2.jpg",
        fileType: "doc",
        fileMimeType: mimeType1,
        // base64Content: "data:${mimeType1};base64,/" + base64String2,
        base64Content: "data:image/jpeg;base64,/" + base64String2,
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      var imageBytes = await image.readAsBytes();
      var fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String base64String3 = base64Encode(imageBytes);

      setState(() {
        _uploadedSignImage = imageBytes;
        _signatureFileName = fileName;
        _signatureBase64 = base64String3;
      });

      Navigator.of(context).pop(); // Close the dialog after selecting an image
    }
  }

  Future<void> _pickImageFromCamera() async {
    var picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      var imageBytes = await image.readAsBytes();
      var fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String base64String4 = base64Encode(imageBytes);

      setState(() {
        _uploadedSignImage = imageBytes;
        _signatureFileName = fileName;
        _signatureBase64 = base64String4;
      });

      Navigator.of(context).pop(); // Close the dialog after selecting an image
    }
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
                    color: Colors.white,
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
            'Reference No : XXXXXXX \n\nYour KYC form is submitted sucessfully and awaiting for verification.',
            style: TextStyle(fontSize: 18, color: primaryBlue),
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
                style: TextStyle(fontSize: 17),
              ),
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(email: widget.personalEmail),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: actionBtnTextColor,
                minimumSize: Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickCustomerPhoto() async {
    final picker = ImagePicker();
    XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      var photoBytes = await photo.readAsBytes();
      var random = Random.secure();
      int randomInt = random.nextInt(1000);
      var photoName = 'user_${DateTime.now().second}_${randomInt}.jpg';
      String base64String5 = base64Encode(photoBytes);

      setState(() {
        _customerPhoto = photoBytes;
        _customerPhotoName = photoName;
      });

      addFileToList(
        fileName: "document3.jpg",
        // fileName: photoName,
        fileType: "cx",
        fileMimeType: "image/jpeg", // Adjust based on file type
        base64Content: "data:image/jpeg;base64,/" + base64String5,
      );
    }
  }

  Widget formOne() {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: DotStepper(
              indicator: Indicator.shift,
              fixedDotDecoration: FixedDotDecoration(color: Colors.grey),
              indicatorDecoration:
                  IndicatorDecoration(color: Colors.blue[900]!),
              dotCount: 8,
              activeStep: activeIndex,
              dotRadius: 15.0,
              shape: Shape.pipe,
              spacing: 10.0,
            ),
          ),
          Text(
            "Step ${activeIndex + 1} of $totalIndex",
            style: TextStyle(
              color: primaryBlue,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20),
          // --------- ID Information Section -------------

          Card(
            // color: cardColor3,
            color: Colors.white,
            elevation: 1,
            shadowColor: primaryBlue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 5, left: 8, right: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ID Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: buttonColor,
                    ),
                    isExpanded: true,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.all(12),
                      labelText: "Select ID Type",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      prefixIconConstraints: BoxConstraints(minWidth: 50),
                      prefixIcon: Icon(
                        color: primaryBlue,
                        Icons.credit_card,
                        size: Responsive.isMobileSmall(context)
                            ? size.width * 0.06
                            : Responsive.isMobileMedium(context)
                                ? size.width * 0.06
                                : Responsive.isMobileLarge(context)
                                    ? size.width * 0.06
                                    : Responsive.isTabletPortrait(context)
                                        ? size.width * 0.035
                                        : size.width * 0.025,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: _selectedType,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedType = newValue!;
                        idTypeController.text = newValue.toString();
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an ID type';
                      }
                      return null;
                    },
                    items: idTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ID Attachment",
                      style: TextStyle(
                        color: normalTextColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? 11
                            : Responsive.isMobileMedium(context)
                                ? 13
                                : Responsive.isMobileLarge(context)
                                    ? 14
                                    : Responsive.isTabletPortrait(context)
                                        ? size.width * 0.02
                                        : size.width * 0.04,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  GestureDetector(
                    onTap: scanDocuments,
                    child: Container(
                      height: 140,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _picture == ""
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file,
                                    size: 40, color: primaryBlue),
                                SizedBox(height: 10),
                                Text(
                                  'Attach Your ID Here',
                                  style: TextStyle(
                                    color: Colors.grey,
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
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _iDSaveName,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // ID Number
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: idNumberController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      fillColor: textFiledFillColor,
                      filled: true,
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'ID Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.credit_card,
                        color: primaryBlue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // TIN Number
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: texPayerNoController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      fillColor: textFiledFillColor,
                      filled: true,
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'TIN Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.payments,
                        color: primaryBlue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     iconAlignment: IconAlignment.end,
          //     icon: Icon(
          //       Icons.arrow_forward,
          //       size: 25,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       setState(() {
          //         activeIndex++;
          //       });
          //       print("id type is $idType");
          //       print("id number is ${idNumberController.text}");
          //       print("TIN Number is ${texPayerNoController.text}");
          //     },
          //     style: ElevatedButton.styleFrom(
          //         backgroundColor: buttonColor,
          //         foregroundColor: actionButtonTextColor,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10.0),
          //         ),
          //         fixedSize: Size(size.width, 50)),
          //     label: Text(
          //       "Save and Next",
          //       style: TextStyle(
          //         fontSize: 20.0,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget formTwo() {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: DotStepper(
              indicator: Indicator.shift,
              fixedDotDecoration: FixedDotDecoration(color: Colors.grey),
              indicatorDecoration:
                  IndicatorDecoration(color: Colors.blue[900]!),
              lineConnectorDecoration:
                  LineConnectorDecoration(color: Colors.yellow),
              dotCount: 8,
              activeStep: activeIndex,
              dotRadius: 15.0,
              shape: Shape.pipe,
              spacing: 10.0,
            ),
          ),
          Text(
            "Step ${activeIndex + 1} of $totalIndex",
            style: TextStyle(
              fontSize: 16.0,
              color: primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          // --------- Personal info Section -------------

          Card(
            color: Colors.white,
            elevation: 1,
            shadowColor: primaryBlue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 1,
                    vertical: 10,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(bottom: 10, left: 8, right: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '  Title',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 5),
                        Wrap(
                          spacing: 10, // Horizontal spacing between tiles
                          runSpacing: 0,
                          children: titles.keys.map((title) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  activeColor: Colors.blue.shade800,
                                  value: titles[title],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      // Uncheck all other titles
                                      titles.updateAll((key, _) => false);
                                      titles[title] = value ?? false;
                                    });
                                  },
                                ),
                                Text(
                                  title,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ]),
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: name1Controller,
                  style: TextStyle(
                      fontSize: Responsive.isMobileSmall(context)
                          ? 15
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? 16
                              : Responsive.isTabletPortrait(context)
                                  ? 18
                                  : 20,
                      height: 1,
                      color: Colors.black),
                  decoration: InputDecoration(
                    fillColor: textFiledFillColor,
                    filled: true,
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: Responsive.isMobileSmall(context)
                          ? size.width * 0.042
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? size.width * 0.04
                              : Responsive.isTabletPortrait(context)
                                  ? size.width * 0.02
                                  : size.width * 0.04,
                    ),
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: primaryBlue,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: name2Controller,
                  style: TextStyle(
                      fontSize: Responsive.isMobileSmall(context)
                          ? 15
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? 16
                              : Responsive.isTabletPortrait(context)
                                  ? 18
                                  : 20,
                      height: 1,
                      color: Colors.black),
                  decoration: InputDecoration(
                    fillColor: textFiledFillColor,
                    filled: true,
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: Responsive.isMobileSmall(context)
                          ? size.width * 0.042
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? size.width * 0.04
                              : Responsive.isTabletPortrait(context)
                                  ? size.width * 0.02
                                  : size.width * 0.04,
                    ),
                    labelText: 'Name with initals',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: primaryBlue,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: name3Controller,
                  style: TextStyle(
                      fontSize: Responsive.isMobileSmall(context)
                          ? 15
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? 16
                              : Responsive.isTabletPortrait(context)
                                  ? 18
                                  : 20,
                      height: 1,
                      color: Colors.black),
                  decoration: InputDecoration(
                    fillColor: textFiledFillColor,
                    filled: true,
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: Responsive.isMobileSmall(context)
                          ? size.width * 0.042
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? size.width * 0.04
                              : Responsive.isTabletPortrait(context)
                                  ? size.width * 0.02
                                  : size.width * 0.04,
                    ),
                    labelText: 'Other names',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: primaryBlue,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding:
                      EdgeInsets.only(top: 20, bottom: 10, left: 2, right: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Date of Birth',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectDate2(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 1,
                      vertical: 2,
                    ),
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: Responsive.isMobileSmall(context)
                                ? 15
                                : Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 16
                                    : Responsive.isTabletPortrait(context)
                                        ? 18
                                        : 20,
                            height: 1.2,
                            color: Colors.black),
                        controller: dobController,
                        decoration: InputDecoration(
                          fillColor: textFiledFillColor,
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide()),
                          prefixIcon: Icon(
                            Icons.calendar_month,
                            size: Responsive.isMobileSmall(context) ||
                                    Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 25
                                : Responsive.isTabletPortrait(context)
                                    ? 30
                                    : 30,
                            color: primaryBlue,
                          ),
                          labelText: "Date of Birth",
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: Responsive.isMobileSmall(context)
                                ? size.width * 0.042
                                : Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? size.width * 0.04
                                    : Responsive.isTabletPortrait(context)
                                        ? size.width * 0.02
                                        : size.width * 0.04,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     iconAlignment: IconAlignment.end,
          //     icon: Icon(
          //       Icons.arrow_forward,
          //       size: 25,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       setState(() {
          //         activeIndex++;
          //       });
          //       print("title is $title");
          //       print("full name is ${name1Controller.text}");
          //       print("name with intials are ${name2Controller.text}");
          //       print("other names are ${name3Controller.text}");
          //       print("dob date is ${dobController.text}");
          //     },
          //     style: ElevatedButton.styleFrom(
          //         backgroundColor: buttonColor,
          //         foregroundColor: actionButtonTextColor,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10.0),
          //         ),
          //         fixedSize: Size(size.width, 50)),
          //     label: Text(
          //       "Save and Next",
          //       style: TextStyle(
          //         fontSize: 20.0,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget formThree() {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: DotStepper(
              indicator: Indicator.shift,
              fixedDotDecoration: FixedDotDecoration(color: Colors.grey),
              indicatorDecoration:
                  IndicatorDecoration(color: Colors.blue[900]!),
              lineConnectorDecoration:
                  LineConnectorDecoration(color: Colors.yellow),
              dotCount: 8,
              activeStep: activeIndex,
              dotRadius: 15.0,
              shape: Shape.pipe,
              spacing: 10.0,
            ),
          ),
          Text(
            "Step ${activeIndex + 1} of $totalIndex",
            style: TextStyle(
              fontSize: 16.0,
              color: primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          // --------- Address Section -------------

          Padding(
            padding: EdgeInsets.only(bottom: 5, left: 8, right: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Address Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Card(
            color: Colors.white,
            elevation: 1,
            shadowColor: primaryBlue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Residential Address',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: primaryBlue,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(12),
                      labelText: "Country",
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      prefixIconConstraints: BoxConstraints(minWidth: 50),
                      prefixIcon: Icon(
                        color: primaryBlue,
                        Icons.flag,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                    ),
                    isExpanded: true,
                    value: selectedCountry,
                    items: countries.map((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCountry = newValue;
                        isSriLankaSelected = (newValue == 'Sri Lanka');
                        selectedProvince = null;
                        selectedDistrict = null;
                        districts.clear();
                        if (!isSriLankaSelected) {
                          stateController.clear();
                        }
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  if (isSriLankaSelected)
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        labelText: 'Province/State',
                        labelStyle: TextStyle(
                          color: wizardFormLabelColor,
                          fontSize: Responsive.isMobileSmall(context)
                              ? size.width * 0.042
                              : Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? size.width * 0.04
                                  : Responsive.isTabletPortrait(context)
                                      ? size.width * 0.02
                                      : size.width * 0.04,
                        ),
                        prefixIconConstraints: BoxConstraints(minWidth: 50),
                        prefixIcon: Icon(
                          color: primaryBlue,
                          Icons.maps_ugc,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(),
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: primaryBlue,
                      ),
                      isExpanded: true,
                      value: selectedProvince,
                      items: provincesInSriLanka.map((province) {
                        return DropdownMenuItem(
                          value: province,
                          child: Text(province),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProvince = value;
                          selectedDistrict = null; // Reset district
                          districts = provinceToDistricts[value] ?? [];
                        });
                      },
                    )
                  else
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: stateController,
                      style: TextStyle(
                          fontSize: Responsive.isMobileSmall(context)
                              ? 15
                              : Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? 16
                                  : Responsive.isTabletPortrait(context)
                                      ? 18
                                      : 20,
                          height: 1,
                          color: primaryBlue),
                      decoration: InputDecoration(
                        labelText: 'State/ Province',
                        labelStyle: TextStyle(
                          color: wizardFormLabelColor,
                          fontSize: Responsive.isMobileSmall(context)
                              ? size.width * 0.042
                              : Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? size.width * 0.04
                                  : Responsive.isTabletPortrait(context)
                                      ? size.width * 0.02
                                      : size.width * 0.04,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(
                          Icons.maps_ugc,
                          color: primaryBlue,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                  SizedBox(height: 10),
                  if (isSriLankaSelected)
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        labelText: 'District',
                        labelStyle: TextStyle(
                          color: wizardFormLabelColor,
                          fontSize: Responsive.isMobileSmall(context)
                              ? size.width * 0.042
                              : Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? size.width * 0.04
                                  : Responsive.isTabletPortrait(context)
                                      ? size.width * 0.02
                                      : size.width * 0.04,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(
                          Icons.map,
                          color: primaryBlue,
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: primaryBlue,
                      ),
                      value: selectedDistrict,
                      items: districts.map((district) {
                        return DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDistrict = value;
                        });
                      },
                    )
                  else
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: districtController,
                      style: TextStyle(
                          fontSize: Responsive.isMobileSmall(context)
                              ? 15
                              : Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? 16
                                  : Responsive.isTabletPortrait(context)
                                      ? 18
                                      : 20,
                          height: 1,
                          color: Colors.white),
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: wizardFormLabelColor,
                          fontSize: Responsive.isMobileSmall(context)
                              ? size.width * 0.042
                              : Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? size.width * 0.04
                                  : Responsive.isTabletPortrait(context)
                                      ? size.width * 0.02
                                      : size.width * 0.04,
                        ),
                        labelText: 'District',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(),
                        ),
                        prefixIcon: Icon(
                          Icons.map,
                          color: primaryBlue,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: cityController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'City',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.location_city,
                        color: primaryBlue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: streetController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'Street Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.streetview,
                        color: primaryBlue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Permanent Address',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        activeColor: primaryBlue,
                        value: isSameAsAbove,
                        onChanged: (value) {
                          setState(() {
                            isSameAsAbove = value!;
                            if (isSameAsAbove) {
                              pAddressController.text =
                                  "Country: ${selectedCountry ?? ''}, Province: ${selectedProvince ?? stateController.text}, District: ${selectedDistrict ?? districtController.text}, City: ${cityController.text}";
                            } else {
                              pAddressController.clear();
                            }
                          });
                        },
                      ),
                      Text(
                        'Same as above',
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  if (!isSameAsAbove)
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: pAddressController,
                      style: TextStyle(
                          fontSize: Responsive.isMobileSmall(context)
                              ? 15
                              : Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? 16
                                  : Responsive.isTabletPortrait(context)
                                      ? 18
                                      : 20,
                          height: 1,
                          color: Colors.black),
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: TextStyle(
                          color: wizardFormLabelColor,
                          fontSize: Responsive.isMobileSmall(context)
                              ? size.width * 0.042
                              : Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? size.width * 0.04
                                  : Responsive.isTabletPortrait(context)
                                      ? size.width * 0.02
                                      : size.width * 0.04,
                        ),
                        labelText: 'Permanent Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(),
                        ),
                        prefixIcon: Icon(
                          Icons.home,
                          color: primaryBlue,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                ],
              ),
            ),
          ),

          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     iconAlignment: IconAlignment.end,
          //     icon: Icon(
          //       Icons.arrow_forward,
          //       size: 25,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       setState(() {
          //         activeIndex++;
          //       });

          //       print("city is ${cityController.text}");
          //       print("distrcit  is ${districtController.text}");
          //       print("state is ${stateController.text}");
          //       print("country is ${countryController.text}");
          //     },
          //     style: ElevatedButton.styleFrom(
          //         backgroundColor: buttonColor,
          //         foregroundColor: actionButtonTextColor,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10.0),
          //         ),
          //         fixedSize: Size(size.width, 50)),
          //     label: Text(
          //       "Save and Next",
          //       style: TextStyle(
          //         fontSize: 20.0,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget formFour() {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: DotStepper(
              indicator: Indicator.shift,
              fixedDotDecoration: FixedDotDecoration(color: Colors.grey),
              indicatorDecoration:
                  IndicatorDecoration(color: Colors.blue[900]!),
              lineConnectorDecoration:
                  LineConnectorDecoration(color: Colors.yellow),
              dotCount: 8,
              activeStep: activeIndex,
              dotRadius: 15.0,
              shape: Shape.pipe,
              spacing: 10.0,
            ),
          ),
          Text(
            "Step ${activeIndex + 1} of $totalIndex",
            style: TextStyle(
              fontSize: 16.0,
              color: primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          // --------- Contact Info Section -------------
          Padding(
            padding: EdgeInsets.only(bottom: 5, left: 8, right: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Card(
            color: Colors.white,
            elevation: 1,
            shadowColor: primaryBlue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: officalEmailController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Official Email',
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: primaryBlue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: perosnlEmailController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 221, 225, 230),
                      enabled: false,
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'Personal Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.alternate_email,
                        color: primaryBlue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Phone No',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: landNumberController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'Landline Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: primaryBlue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: mobileController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.phone_android_outlined,
                        color: primaryBlue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     iconAlignment: IconAlignment.end,
          //     icon: Icon(
          //       Icons.arrow_forward,
          //       size: 25,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       setState(() {
          //         activeIndex++;
          //       });

          //       print("official mail is ${officalEmailController.text}");
          //       print("landline no  is ${landNumberController.text}");
          //       print("mobile no is ${mobileController.text}");
          //       print("personal email is ${perosnlEmailController.text}");
          //     },
          //     style: ElevatedButton.styleFrom(
          //         backgroundColor: buttonColor,
          //         foregroundColor: actionButtonTextColor,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10.0),
          //         ),
          //         fixedSize: Size(size.width, 50)),
          //     label: Text(
          //       "Save and Next",
          //       style: TextStyle(
          //         fontSize: 20.0,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget formFive() {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: DotStepper(
              indicator: Indicator.shift,
              fixedDotDecoration: FixedDotDecoration(color: Colors.grey),
              indicatorDecoration:
                  IndicatorDecoration(color: Colors.blue[900]!),
              lineConnectorDecoration:
                  LineConnectorDecoration(color: Colors.yellow),
              dotCount: 8,
              activeStep: activeIndex,
              dotRadius: 15.0,
              shape: Shape.pipe,
              spacing: 10.0,
            ),
          ),
          Text(
            "Step ${activeIndex + 1} of $totalIndex",
            style: TextStyle(
              fontSize: 16.0,
              color: primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          // ---------  Occupation Details Section -------------

          Padding(
            padding: EdgeInsets.only(bottom: 5, left: 8, right: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Occupation Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Card(
            color: Colors.white,
            elevation: 1,
            shadowColor: primaryBlue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  //-------- Name of Employer-------------
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: employerNameController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'Employer Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(
                        Icons.person_4,
                        color: primaryBlue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Address of Employer
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: employerAddressController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'Employer Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.home_repair_service,
                        color: primaryBlue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Telephone
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: employerPhoneController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'Telephone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: primaryBlue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Email
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: employerEmailController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.email_sharp,
                        color: primaryBlue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Current Position
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: employerPositionController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'Current Position',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.business_center,
                        color: primaryBlue,
                        // color: Colors.blue.shade800,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Documents",
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: Responsive.isMobileSmall(context)
                            ? 11
                            : Responsive.isMobileMedium(context)
                                ? 14
                                : Responsive.isMobileLarge(context)
                                    ? 15
                                    : Responsive.isTabletPortrait(context)
                                        ? size.width * 0.02
                                        : size.width * 0.04,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                      onTap: attachEmployeeFiles,
                      child: Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade600),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _uploadEmployeeDocumentation == ""
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file,
                                      size: 40, color: primaryBlue),
                                  SizedBox(height: 10),
                                  Text(
                                    'Upload Documents',
                                    style: TextStyle(
                                      color: wizardFormLabelColor,
                                      fontSize:
                                          Responsive.isMobileSmall(context)
                                              ? size.width * 0.042
                                              : Responsive.isMobileMedium(
                                                          context) ||
                                                      Responsive.isMobileLarge(
                                                          context)
                                                  ? size.width * 0.04
                                                  : Responsive.isTabletPortrait(
                                                          context)
                                                      ? size.width * 0.02
                                                      : size.width * 0.04,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _uploadEmployeeDocumentation,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ],
                              ),
                      )),
                ],
              ),
            ),
          ),

          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     iconAlignment: IconAlignment.end,
          //     icon: Icon(
          //       Icons.arrow_forward,
          //       size: 25,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       setState(() {
          //         activeIndex++;
          //       });
          //       print("employer name is ${employerNameController.text}");
          //       print("address  is ${employerAddressController.text}");
          //       print("telephone is ${employerPhoneController.text}");
          //       print("email is ${employerEmailController.text}");
          //       print("position is ${employerPositionController.text}");
          //     },
          //     style: ElevatedButton.styleFrom(
          //         backgroundColor: buttonColor,
          //         foregroundColor: actionButtonTextColor,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10.0),
          //         ),
          //         fixedSize: Size(size.width, 50)),
          //     label: Text(
          //       "Save and Next",
          //       style: TextStyle(
          //         fontSize: 20.0,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget formSix() {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: DotStepper(
              indicator: Indicator.shift,
              fixedDotDecoration: FixedDotDecoration(color: Colors.grey),
              indicatorDecoration:
                  IndicatorDecoration(color: Colors.blue[900]!),
              lineConnectorDecoration:
                  LineConnectorDecoration(color: Colors.yellow),
              dotCount: 8,
              activeStep: activeIndex,
              dotRadius: 15.0,
              shape: Shape.pipe,
              spacing: 10.0,
            ),
          ),
          Text(
            "Step ${activeIndex + 1} of $totalIndex",
            style: TextStyle(
              fontSize: 16.0,
              color: primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          // ---------  Buisness Details Section -------------

          Padding(
            padding: EdgeInsets.only(bottom: 5, left: 8, right: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Business Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Card(
            color: Colors.white,
            elevation: 1,
            shadowColor: primaryBlue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(top: 10, bottom: 5, left: 8, right: 8),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Nature of Business',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black,
                      ),
                      keyboardType: TextInputType.text,
                      controller: businessNatureController,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: TextStyle(
                          color: wizardFormLabelColor,
                          fontSize: Responsive.isMobileSmall(context)
                              ? size.width * 0.042
                              : Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? size.width * 0.04
                                  : Responsive.isTabletPortrait(context)
                                      ? size.width * 0.02
                                      : size.width * 0.04,
                        ),
                        labelText: 'Nature of Business',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(),
                        ),
                        prefixIcon: Icon(
                          Icons.business,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 10, bottom: 5, left: 8, right: 8),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Connected Businesses and Interests',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                    child: TextFormField(
                      style: TextStyle(
                          fontSize: Responsive.isMobileSmall(context)
                              ? 15
                              : Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? 16
                                  : Responsive.isTabletPortrait(context)
                                      ? 18
                                      : 20,
                          height: 1,
                          color: Colors.black),
                      keyboardType: TextInputType.text,
                      controller: connectedBusinessController,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: TextStyle(
                          color: wizardFormLabelColor,
                          fontSize: Responsive.isMobileSmall(context)
                              ? size.width * 0.042
                              : Responsive.isMobileMedium(context) ||
                                      Responsive.isMobileLarge(context)
                                  ? size.width * 0.04
                                  : Responsive.isTabletPortrait(context)
                                      ? size.width * 0.02
                                      : size.width * 0.04,
                        ),
                        labelText: 'Connected Businesses',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(),
                        ),
                        prefixIcon: Icon(
                          Icons.business,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     iconAlignment: IconAlignment.end,
          //     icon: Icon(
          //       Icons.arrow_forward,
          //       size: 25,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       setState(() {
          //         activeIndex++;
          //       });
          //       print("business nature is ${businessNatureController.text}");
          //       print(
          //           "cnnected business is ${connectedBusinessController.text}");
          //     },
          //     style: ElevatedButton.styleFrom(
          //         backgroundColor: buttonColor,
          //         foregroundColor: actionButtonTextColor,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10.0),
          //         ),
          //         fixedSize: Size(size.width, 50)),
          //     label: Text(
          //       "Save and Next",
          //       style: TextStyle(
          //         fontSize: 20.0,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget formSeven() {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: DotStepper(
              indicator: Indicator.shift,
              fixedDotDecoration: FixedDotDecoration(color: Colors.grey),
              indicatorDecoration:
                  IndicatorDecoration(color: Colors.blue[900]!),
              lineConnectorDecoration:
                  LineConnectorDecoration(color: Colors.yellow),
              dotCount: 8,
              activeStep: activeIndex,
              dotRadius: 15.0,
              shape: Shape.pipe,
              spacing: 10.0,
            ),
          ),
          Text(
            "Step ${activeIndex + 1} of $totalIndex",
            style: TextStyle(
              fontSize: 16.0,
              color: primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          // ---------  Financial Details Section -------------

          Padding(
            padding: EdgeInsets.only(bottom: 5, left: 8, right: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Financial Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 1,
            shadowColor: primaryBlue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  //------- Source of Funds--------------------
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: fundSourcesController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'Source of Funds',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(
                        Icons.account_balance,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // ----------Source of Wealth------------------
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: wealthSourcesController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'Source of Wealth',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.account_balance_wallet,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  //----------- Monthly income --------------
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: incomeController,
                    style: TextStyle(
                        fontSize: Responsive.isMobileSmall(context)
                            ? 15
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 16
                                : Responsive.isTabletPortrait(context)
                                    ? 18
                                    : 20,
                        height: 1,
                        color: Colors.black),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: wizardFormLabelColor,
                        fontSize: Responsive.isMobileSmall(context)
                            ? size.width * 0.042
                            : Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? size.width * 0.04
                                : Responsive.isTabletPortrait(context)
                                    ? size.width * 0.02
                                    : size.width * 0.04,
                      ),
                      labelText: 'Monthly Income',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(),
                      ),
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: ElevatedButton.icon(
          //     iconAlignment: IconAlignment.end,
          //     icon: Icon(
          //       Icons.arrow_forward,
          //       size: 25,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       setState(() {
          //         activeIndex++;
          //       });

          //       print("source of funds is ${fundSourcesController.text}");
          //       print("source of wealth is ${wealthSourcesController.text}");
          //       print("income is ${incomeController.text}");
          //     },
          //     style: ElevatedButton.styleFrom(
          //         backgroundColor: buttonColor,
          //         foregroundColor: actionButtonTextColor,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10.0),
          //         ),
          //         fixedSize: Size(size.width, 50)),
          //     label: Text(
          //       "Save and Next",
          //       style: TextStyle(
          //         fontSize: 20.0,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget formEight() {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: DotStepper(
              indicator: Indicator.shift,
              fixedDotDecoration: FixedDotDecoration(color: Colors.grey),
              indicatorDecoration:
                  IndicatorDecoration(color: Colors.blue[900]!),
              lineConnectorDecoration:
                  LineConnectorDecoration(color: Colors.yellow),
              dotCount: 8,
              activeStep: activeIndex,
              dotRadius: 15.0,
              shape: Shape.pipe,
              spacing: 10.0,
            ),
          ),
          Text(
            "Step ${activeIndex + 1} of $totalIndex",
            style: TextStyle(
              fontSize: 16.0,
              color: primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          // ---------  Financial Details Section -------------

          Padding(
            padding: EdgeInsets.only(bottom: 5, left: 8, right: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 1,
            shadowColor: primaryBlue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          _signatureImage != null || _uploadedSignImage != null
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Signature",
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontSize: Responsive.isMobileSmall(
                                                context)
                                            ? 11
                                            : Responsive.isMobileMedium(context)
                                                ? 13
                                                : Responsive.isMobileLarge(
                                                        context)
                                                    ? 14
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.width * 0.02
                                                        : size.width * 0.04,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(height: 1),
                          GestureDetector(
                            onTap: _showSignatureDialog,
                            child: Container(
                              height: 120,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade600),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _uploadedSignImage != null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            _signatureFileName,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    )
                                  : _signatureImage == null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit,
                                                size: 40, color: primaryBlue),
                                            SizedBox(height: 10),
                                            Text(
                                              'Add Signature',
                                              style: TextStyle(
                                                color: wizardFormLabelColor,
                                                fontSize: Responsive
                                                        .isMobileSmall(context)
                                                    ? size.width * 0.042
                                                    : Responsive.isMobileMedium(
                                                                context) ||
                                                            Responsive
                                                                .isMobileLarge(
                                                                    context)
                                                        ? size.width * 0.04
                                                        : Responsive
                                                                .isTabletPortrait(
                                                                    context)
                                                            ? size.width * 0.02
                                                            : size.width * 0.04,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                _signatureFileName,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          _customerPhoto != null
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "User Photo",
                                      style: TextStyle(
                                        color: wizardFormLabelColor,
                                        fontSize: Responsive.isMobileSmall(
                                                context)
                                            ? 11
                                            : Responsive.isMobileMedium(context)
                                                ? 13
                                                : Responsive.isMobileLarge(
                                                        context)
                                                    ? 14
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.width * 0.02
                                                        : size.width * 0.04,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(height: 1),
                          GestureDetector(
                            onTap: _pickCustomerPhoto,
                            child: Container(
                              height: 120,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade600),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _customerPhoto == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt,
                                            size: 40, color: primaryBlue),
                                        SizedBox(height: 10),
                                        Text(
                                          'Upload Photo',
                                          style: TextStyle(
                                            color: wizardFormLabelColor,
                                            fontSize: Responsive.isMobileSmall(
                                                    context)
                                                ? size.width * 0.042
                                                : Responsive.isMobileMedium(
                                                            context) ||
                                                        Responsive
                                                            .isMobileLarge(
                                                                context)
                                                    ? size.width * 0.04
                                                    : Responsive
                                                            .isTabletPortrait(
                                                                context)
                                                        ? size.width * 0.02
                                                        : size.width * 0.04,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            _customerPhotoName ?? '',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _selectDate1(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: Responsive.isMobileSmall(context)
                                ? 15
                                : Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? 16
                                    : Responsive.isTabletPortrait(context)
                                        ? 18
                                        : 20,
                            height: 1.2,
                            color: Colors.black),
                        controller: visaController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(
                            Icons.calendar_month,
                            size: Responsive.isMobileSmall(context) ||
                                    Responsive.isMobileMedium(context) ||
                                    Responsive.isMobileLarge(context)
                                ? 25
                                : Responsive.isTabletPortrait(context)
                                    ? 30
                                    : 30,
                            color: primaryBlue,
                          ),
                          labelText: "VISA Expiry Date",
                          labelStyle: TextStyle(
                            color: wizardFormLabelColor,
                            fontSize: Responsive.isMobileSmall(context)
                                ? size.width * 0.042
                                : Responsive.isMobileMedium(context) ||
                                        Responsive.isMobileLarge(context)
                                    ? size.width * 0.04
                                    : Responsive.isTabletPortrait(context)
                                        ? size.width * 0.02
                                        : size.width * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: ElevatedButton(
          //     iconAlignment: IconAlignment.end,
          //     onPressed: () {
          //       print("vis expire date is ${visaController.text}");
          //       print("signature name  is $_signatureFileName");
          //       print("customer photo is $_customerPhotoName");
          //       _showConfirmationDialog(context);
          //     },
          //     style: ElevatedButton.styleFrom(
          //         backgroundColor: buttonColor,
          //         foregroundColor: actionButtonTextColor,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10.0),
          //         ),
          //         fixedSize: Size(size.width, 50)),
          //     child: Text(
          //       "Submit Form",
          //       style: TextStyle(
          //         fontSize: 20.0,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}

  void _showSignatureDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          int selectedTab = 0;
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.0),
                  child: Text(
                    'Add Signature',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            titlePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 320,
              child: StatefulBuilder(
                builder: (context, _setState) => Column(
                  children: [
                    Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Text(
                            'Signature Pad',
                            style: TextStyle(fontSize: 15),
                          ),
                          leading: Radio<int>(
                            value: 0,
                            groupValue: selectedTab,
                            onChanged: (int? value) {
                              _setState(() {
                                selectedTab = value!;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Text(
                            'Upload',
                            style: TextStyle(fontSize: 15),
                          ),
                          leading: Radio<int>(
                            value: 1,
                            groupValue: selectedTab,
                            onChanged: (int? value) {
                              _setState(() {
                                selectedTab = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    if (selectedTab == 0)
                      Column(
                        children: [
                          Signature(
                            controller: _signatureController,
                            height: 150,
                            backgroundColor: Colors.grey[200]!,
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () => _signatureController.clear(),
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[400],
                                  minimumSize: Size(110, 35),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_signatureController.isNotEmpty) {
                                    var image =
                                        await _signatureController.toImage();
                                    var byteData = await image!.toByteData(
                                        format: ImageByteFormat.png);
                                    var imageBytes =
                                        byteData!.buffer.asUint8List();

                                    // Generate a random filename
                                    var fileName =
                                        'signature_${DateTime.now().millisecondsSinceEpoch}.jpg';

                                    String base64String5 =
                                        base64Encode(imageBytes);

                                    // Save image and filename
                                    setState(() {
                                      _signatureImage = imageBytes;
                                      _signatureFileName = fileName;
                                      _signatureBase64 = base64String5;
                                    });

                                    print("file name is $fileName");
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Please add a signature.')),
                                    );
                                  }
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  minimumSize: Size(110, 35),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else if (selectedTab == 1)
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImageFromGallery,
                            icon: Icon(Icons.upload),
                            label: Text(
                              'Upload from Gallery',
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black54,
                              minimumSize: Size(110, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          ElevatedButton.icon(
                            onPressed: _pickImageFromCamera,
                            icon: Icon(Icons.upload),
                            label: Text(
                              'Upload from Camera',
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black54,
                              minimumSize: Size(110, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        });
    // },
    // );
  }

  Widget bodyBuilder() {
    switch (activeIndex) {
      case 0:
        return formOne();
      case 1:
        return formTwo();
      case 2:
        return formThree();
      case 3:
        return formFour();
      case 4:
        return formFive();
      case 5:
        return formSix();
      case 6:
        return formSeven();
      case 7:
        return formEight();

      default:
        return formOne();
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
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: true,
        elevation: 10,
        centerTitle: true,
        title: Text(
          "KYC Form",
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
        padding: EdgeInsets.symmetric(horizontal: 5),
        height: size.height,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Container(
                  padding: EdgeInsets.all(12),
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
                    width: Responsive.isMobileSmall(context) ? 120 : 100,
                    height: Responsive.isMobileSmall(context) ? 75 : 75,
                  ),
                ),
              ),
              // SizedBox(height: 20),
              // Text(
              //   "KYC Form",
              //   style: TextStyle(fontSize: 25, color: primaryBlue),
              // ),
              SizedBox(height: 10),
              bodyBuilder(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: activeIndex == 7
            ? ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: actionButtonTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    fixedSize: Size(size.width, 50)),
                child: Text(
                  "Submit Form",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              )
            : ElevatedButton.icon(
                iconAlignment: IconAlignment.end,
                icon: Icon(
                  Icons.arrow_forward,
                  size: 25,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (activeIndex != 7) {
                    setState(() {
                      activeIndex++;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: actionButtonTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    fixedSize: Size(size.width, 50)),
                label: Text(
                  "Save and Next",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked1 = await showDatePicker(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: buttonColor!,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );

    if (picked1 != null) {
      setState(() {
        visaController.text = DateFormat('yyyy-MM-dd').format(picked1);
      });
    }
  }

  Future<void> _selectDate2(BuildContext context) async {
    final DateTime? picked2 = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: buttonColor!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );
    if (picked2 != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(picked2);
      });
    }
  }
}
