import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lankapay_shared_kyc/constants/constants.dart';
import 'package:lankapay_shared_kyc/constants/responsive.dart';
import 'package:lankapay_shared_kyc/screens/login-register/login_screen.dart';
import 'package:lankapay_shared_kyc/screens/settings/settings.dart';
import 'package:signature/signature.dart';

class EditKYCForm extends StatefulWidget {
  const EditKYCForm({super.key});

  @override
  State<EditKYCForm> createState() => _EditKYCFormState();
}

class _EditKYCFormState extends State<EditKYCForm> {
  final idNumberController = new TextEditingController();
  final titleController = new TextEditingController();
  final idTypeController = new TextEditingController();
  final nameController = new TextEditingController();
  final dobController = new TextEditingController();
  final addressController = new TextEditingController();
  final texPayerNoController = new TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final landNumberController = TextEditingController();
  final mobileController = TextEditingController();
  final perosnlEmailController = TextEditingController();
  final officalEmailController = new TextEditingController();
  final taxpayerController = new TextEditingController();
  final pepInfoController = new TextEditingController();
  final photoController = new TextEditingController();
  final visaController = new TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );
  String? _selectedType;
  File? imageFile;
  FilePickerResult? result;
  String attachedFileBase64String = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> idTypes = ['NIC', 'Passport', 'Driving License'];
  Uint8List? _signatureImage;
  Uint8List? _uploadedSignImage;
  String? _signatureFileName;
  String? _iDSaveName;
  String? _customerPhotoName;
  List<String> _pictures = [];
  String _picture = "";
  Uint8List? _customerPhoto;

  @override
  void initState() {
    super.initState();
    initPlatformState();
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

  void onPressed() async {
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

      // Read file as bytes and encode to Base64
      final bytes = File(pic).readAsBytesSync();
      base64String = base64Encode(bytes);

      if (!mounted) return;
      setState(() {
        _pictures = pictures;
        _picture = pic;
        _iDSaveName = fileName;
      });

      print(_pictures);

      print("Base64 String: $base64String");
    } catch (exception) {
      // Handle exception here
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}

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
          icon: Icon(
            Icons.arrow_back,
            color: appBarIconColor,
          ),
        ),
        automaticallyImplyLeading: true,
        elevation: 10,
        centerTitle: true,
        backgroundColor: appBarColor,
        actions: <Widget>[
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
                color: appBarIconColor,
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
                color: appBarIconColor,
              ),
            ),
          ),
        ],
      ),
      body: Container(
          child: SingleChildScrollView(
        child: Column(children: [
          Image.asset(
            // 'assets/images/E-kyc_logo.png',
            'assets/images/lankapay_logo-removebg.png',
            width: Responsive.isMobileSmall(context) ? 200 : 250,
            height: Responsive.isMobileSmall(context) ? 100 : 130,
          ),
          Text(
            "Edit KYC Form",
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Column(
              children: [
                // --------- ID Information Section -------------

                Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 5, left: 8, right: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'ID Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Card(
                  color: Color.fromARGB(255, 234, 241, 252),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(12),
                            labelText: "Select ID Type",
                            labelStyle: TextStyle(
                              color: Colors.black54,
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
                              color: Colors.grey[500],
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
                            "Attached ID",
                            style: TextStyle(
                              color: Colors.black54,
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
                        GestureDetector(
                          onTap: onPressed,
                          child: Container(
                            height: 120,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: _picture == ""
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.upload_file,
                                          size: 40, color: Colors.grey[400]),
                                      SizedBox(height: 10),
                                      Text(
                                        'Attach Your ID Here',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: Responsive.isMobileSmall(
                                                  context)
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
                                        _iDSaveName ?? '',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: 10),

                        // ID Number
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: idNumberController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: Responsive.isMobileSmall(context)
                                  ? size.width * 0.042
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.04
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.02
                                          : size.width * 0.04,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'ID Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.credit_card,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 1,
                    vertical: 10,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Title',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 70, // Horizontal spacing between tiles
                          runSpacing: 0,
                          children: titles.keys.map((title) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: titles[title],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      titles[title] = value ?? false;
                                    });
                                  },
                                ),
                                Text(
                                  title,
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 17),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ]),
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: nameController,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: Responsive.isMobileSmall(context)
                          ? size.width * 0.042
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? size.width * 0.04
                              : Responsive.isTabletPortrait(context)
                                  ? size.width * 0.02
                                  : size.width * 0.04,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'FullName',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(
                      Icons.credit_card,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: dobController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
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
                            color: Colors.grey[500],
                          ),
                          labelText: "Date of Birth",
                          labelStyle: TextStyle(
                            color: Colors.black54,
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
                ),
                // formComponent(
                //     context,
                //     size,
                //     "Permanent Address",
                //     Icons.home,
                //     "Enter your Address",
                //     TextInputType.text,
                //     10,
                //     addressController),

                // --------- Permanent Address Section -------------

                Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 5, left: 8, right: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Permanent Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Card(
                  color: Color.fromARGB(255, 234, 241, 252),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: cityController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.location_city,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: districtController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'District',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.map,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: stateController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'State/ Province',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.maps_ugc,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: countryController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Country',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.flag,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: countryController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Postal Code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.local_post_office_rounded,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // --------- Residential Address Section -------------

                Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 5, left: 8, right: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Residential Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Card(
                  color: Color.fromARGB(255, 234, 241, 252),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: cityController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.location_city,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: districtController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'District',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.map,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: stateController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'State/ Province',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.maps_ugc,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: countryController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Country',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.flag,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: countryController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Postal Code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.local_post_office_rounded,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // --------- Contact Number Section -------------

                Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 5, left: 8, right: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Contact Number',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Card(
                  color: Color.fromARGB(255, 234, 241, 252),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    child: Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: landNumberController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Landline',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: mobileController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Mobile',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.phone_android,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // --------- Email Section -------------

                Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 5, left: 8, right: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Card(
                  color: Color.fromARGB(255, 234, 241, 252),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    child: Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: officalEmailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Official',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: perosnlEmailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Personal',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.alternate_email,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Taxpayer Identification Number
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: taxpayerController,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: Responsive.isMobileSmall(context)
                          ? size.width * 0.042
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? size.width * 0.04
                              : Responsive.isTabletPortrait(context)
                                  ? size.width * 0.02
                                  : size.width * 0.04,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Taxpayer Identification Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(
                      Icons.credit_card,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Political Exposed Person Info
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: pepInfoController,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: Responsive.isMobileSmall(context)
                          ? size.width * 0.042
                          : Responsive.isMobileMedium(context) ||
                                  Responsive.isMobileLarge(context)
                              ? size.width * 0.04
                              : Responsive.isTabletPortrait(context)
                                  ? size.width * 0.02
                                  : size.width * 0.04,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Political Exposed Person Info',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(
                      Icons.credit_card,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // --------- Occupation Details Section -------------

                Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 5, left: 8, right: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Occupation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Card(
                  color: Color.fromARGB(255, 234, 241, 252),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      children: [
                        // Name of Employer
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: idNumberController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: Responsive.isMobileSmall(context)
                                  ? size.width * 0.042
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.04
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.02
                                          : size.width * 0.04,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Employer Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.person_4,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Address of Employer
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: idNumberController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: Responsive.isMobileSmall(context)
                                  ? size.width * 0.042
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.04
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.02
                                          : size.width * 0.04,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Employer Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.home_repair_service,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Telephone
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: idNumberController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: Responsive.isMobileSmall(context)
                                  ? size.width * 0.042
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.04
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.02
                                          : size.width * 0.04,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Telephone',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Email
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: idNumberController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: Responsive.isMobileSmall(context)
                                  ? size.width * 0.042
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.04
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.02
                                          : size.width * 0.04,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.email_sharp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Current Position
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: idNumberController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: Responsive.isMobileSmall(context)
                                  ? size.width * 0.042
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.04
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.02
                                          : size.width * 0.04,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Current Position',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.business_center,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // --------- Financial Details Section -------------

                Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 5, left: 8, right: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Financial Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Card(
                  color: Color.fromARGB(255, 234, 241, 252),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      children: [
                        // Source of Funds
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: idNumberController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: Responsive.isMobileSmall(context)
                                  ? size.width * 0.042
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.04
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.02
                                          : size.width * 0.04,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Source of Funds',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.account_balance,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Source of Wealth
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: idNumberController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: Responsive.isMobileSmall(context)
                                  ? size.width * 0.042
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.04
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.02
                                          : size.width * 0.04,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Source of Wealth',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.account_balance_wallet,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Current Position
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: idNumberController,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: Responsive.isMobileSmall(context)
                                  ? size.width * 0.042
                                  : Responsive.isMobileMedium(context) ||
                                          Responsive.isMobileLarge(context)
                                      ? size.width * 0.04
                                      : Responsive.isTabletPortrait(context)
                                          ? size.width * 0.02
                                          : size.width * 0.04,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Monthly Income',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.attach_money,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // --------- Additional Details Section -------------

                Padding(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 5, left: 8, right: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Card(
                    color: Color.fromARGB(255, 234, 241, 252),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // GestureDetector(
                              //   onTap: _showSignaturePad,
                              //   child: Container(
                              //     height: 120,
                              //     width:
                              //         MediaQuery.of(context).size.width * 0.4,
                              //     decoration: BoxDecoration(
                              //       border: Border.all(color: Colors.black54),
                              //       borderRadius: BorderRadius.circular(12),
                              //       color: Colors.white,
                              //     ),
                              //     child: signatureImage == null
                              //         ? Column(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.center,
                              //             children: [
                              //               Icon(Icons.edit,
                              //                   size: 40,
                              //                   color: Colors.grey[400]),
                              //               SizedBox(height: 10),
                              //               Text(
                              //                 'Add Signature',
                              //                 style: TextStyle(
                              //                   color: Colors.black54,
                              //                   fontSize: Responsive
                              //                           .isMobileSmall(context)
                              //                       ? size.width * 0.042
                              //                       : Responsive.isMobileMedium(
                              //                                   context) ||
                              //                               Responsive
                              //                                   .isMobileLarge(
                              //                                       context)
                              //                           ? size.width * 0.04
                              //                           : Responsive
                              //                                   .isTabletPortrait(
                              //                                       context)
                              //                               ? size.width * 0.02
                              //                               : size.width * 0.04,
                              //                 ),
                              //               ),
                              //             ],
                              //           )
                              //         : Column(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.center,
                              //             children: [
                              //               // Image.memory(
                              //               //   signatureImage!,
                              //               //   height: 100,
                              //               //   width: double.infinity,
                              //               //   fit: BoxFit.contain,
                              //               // ),
                              //               // SizedBox(height: 5),
                              //               Text(
                              //                 signatureFileName ?? '',
                              //                 style: TextStyle(
                              //                     fontSize: 14,
                              //                     color: Colors.black54),
                              //               ),
                              //             ],
                              //           ),
                              //   ),
                              // ),

                              Column(
                                children: [
                                  _signatureImage != null ||
                                          _uploadedSignImage != null
                                      ? Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            " Signature",
                                            style: TextStyle(
                                              color: const Color.fromARGB(
                                                  137, 73, 66, 66),
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 11
                                                  : Responsive.isMobileMedium(
                                                          context)
                                                      ? 13
                                                      : Responsive.isMobileLarge(
                                                              context)
                                                          ? 14
                                                          : Responsive
                                                                  .isTabletPortrait(
                                                                      context)
                                                              ? size.width *
                                                                  0.02
                                                              : size.width *
                                                                  0.04,
                                            ),
                                          ),
                                        )
                                      : SizedBox(height: 1),
                                  GestureDetector(
                                    onTap: _showSignatureDialog,
                                    child: Container(
                                      height: 120,
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black54),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      child: _uploadedSignImage != null
                                          ?
                                          // Image.memory(_uploadedSignImage!)
                                          Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    _signatureFileName ?? '',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54),
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
                                                        size: 40,
                                                        color:
                                                            Colors.grey[400]),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      'Add Signature',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: Responsive
                                                                .isMobileSmall(
                                                                    context)
                                                            ? size.width * 0.042
                                                            : Responsive.isMobileMedium(
                                                                        context) ||
                                                                    Responsive
                                                                        .isMobileLarge(
                                                                            context)
                                                                ? size.width *
                                                                    0.04
                                                                : Responsive.isTabletPortrait(
                                                                        context)
                                                                    ? size.width *
                                                                        0.02
                                                                    : size.width *
                                                                        0.04,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // Image.memory(
                                                    //   signatureImage!,
                                                    //   height: 100,
                                                    //   width: double.infinity,
                                                    //   fit: BoxFit.contain,
                                                    // ),
                                                    // SizedBox(height: 5),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        _signatureFileName ??
                                                            '',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.black54),
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
                                      ? Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "User Photo",
                                            style: TextStyle(
                                              color: const Color.fromARGB(
                                                  137, 73, 66, 66),
                                              fontSize: Responsive
                                                      .isMobileSmall(context)
                                                  ? 11
                                                  : Responsive.isMobileMedium(
                                                          context)
                                                      ? 13
                                                      : Responsive.isMobileLarge(
                                                              context)
                                                          ? 14
                                                          : Responsive
                                                                  .isTabletPortrait(
                                                                      context)
                                                              ? size.width *
                                                                  0.02
                                                              : size.width *
                                                                  0.04,
                                            ),
                                          ),
                                        )
                                      : SizedBox(height: 1),
                                  GestureDetector(
                                    onTap: _pickCustomerPhoto,
                                    child: Container(
                                      height: 120,
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black54),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      child: _customerPhoto == null
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.camera_alt,
                                                    size: 40,
                                                    color: Colors.grey[400]),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Upload Photo',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: Responsive
                                                            .isMobileSmall(
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
                                                                ? size.width *
                                                                    0.02
                                                                : size.width *
                                                                    0.04,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // Image.memory(
                                                //   signatureImage!,
                                                //   height: 100,
                                                //   width: double.infinity,
                                                //   fit: BoxFit.contain,
                                                // ),
                                                // SizedBox(height: 5),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    _customerPhotoName ?? '',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54),
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
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: dobController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
                                    size: Responsive.isMobileSmall(context) ||
                                            Responsive.isMobileMedium(
                                                context) ||
                                            Responsive.isMobileLarge(context)
                                        ? 25
                                        : Responsive.isTabletPortrait(context)
                                            ? 30
                                            : 30,
                                    color: Colors.grey[500],
                                  ),
                                  labelText: "VISA Expiry Date",
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
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    )),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        'Reset',
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        minimumSize: Size(140, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        'Submit',
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(140, 40),
                        backgroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50)
              ],
            ),
          ),
        ]),
      )),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue[900]!,
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
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        visaController.text = DateFormat('dd/MM/yyyy').format(picked);
        dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageBytes = await image.readAsBytes();
      final fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.jpg';

      setState(() {
        _uploadedSignImage = imageBytes;
        _signatureFileName = fileName;
      });
      Navigator.of(context).pop(); // Close the dialog after selecting an image
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final imageBytes = await image.readAsBytes();
      final fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.jpg';

      setState(() {
        _uploadedSignImage = imageBytes;
        _signatureFileName = fileName;
      });

      Navigator.of(context).pop(); // Close the dialog after selecting an image
    }
  }

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
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
                                  // if (_signatureController.isNotEmpty) {
                                  //   final signature =
                                  //       await _signatureController.toPngBytes();
                                  //   if (signature != null) {
                                  //     setState(() {
                                  //       _signatureImage = signature;
                                  //     });
                                  //     Navigator.of(context).pop();
                                  //   }
                                  // }

                                  if (_signatureController.isNotEmpty) {
                                    final image =
                                        await _signatureController.toImage();
                                    final byteData = await image!.toByteData(
                                        format: ImageByteFormat.png);
                                    final imageBytes =
                                        byteData!.buffer.asUint8List();

                                    // Generate a random filename
                                    final fileName =
                                        'signature_${DateTime.now().millisecondsSinceEpoch}.jpg';

                                    // Save image and filename
                                    setState(() {
                                      _signatureImage = imageBytes;
                                      _signatureFileName = fileName;
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
                                  backgroundColor: Colors.blue[900],
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

  Future<void> _pickCustomerPhoto() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      final photoBytes = await photo.readAsBytes();
      var random = Random.secure();
      int randomInt = random.nextInt(1000);
      final photoName = 'user_${DateTime.now().second}_${randomInt}.jpg';

      setState(() {
        _customerPhoto = photoBytes;
        _customerPhotoName = photoName;
      });
    }
  }
}
