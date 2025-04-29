import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lankapay_shared_kyc/constants/responsive.dart';

closeDialog(context) {
  Navigator.of(context).pop();
}

showWarningDialogPopup(
    BuildContext context, IconData icon, String message, Function okHandler) {
  Size size = MediaQuery.of(context).size;

  // show the dialog
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: Container(
          width: Responsive.isMobileSmall(context) ||
                  Responsive.isMobileMedium(context) ||
                  Responsive.isMobileLarge(context)
              ? size.width * 0.75
              : Responsive.isTabletPortrait(context)
                  ? size.width * 0.6
                  : size.width * 0.5,
          height: Responsive.isMobileSmall(context) ||
                  Responsive.isMobileMedium(context) ||
                  Responsive.isMobileLarge(context)
              ? 280
              : Responsive.isTabletPortrait(context)
                  ? 300
                  : 320,
          padding: EdgeInsets.fromLTRB(30, 15, 30, 10),
          color: Color.fromARGB(255, 218, 216, 216),
          child: Column(
            children: <Widget>[
              SizedBox(height: 15),
              Icon(icon,
                  size: Responsive.isMobileSmall(context)
                      ? 60
                      : Responsive.isMobileMedium(context) ||
                              Responsive.isMobileLarge(context)
                          ? 65
                          : Responsive.isTabletPortrait(context)
                              ? 75
                              : 80,
                  color: Colors.red),
              SizedBox(height: 15),
              Text(
                textAlign: TextAlign.center,
                message,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Color.fromARGB(255, 243, 46, 32),
                    height: 1.3,
                    fontSize: Responsive.isMobileSmall(context)
                        ? 17.5
                        : Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 19
                            : Responsive.isTabletPortrait(context)
                                ? 22
                                : 24,
                    fontFamily: "open sans",
                    fontWeight: FontWeight.w400),
                textScaler: TextScaler.linear(1),
              ),
              SizedBox(height: 30),
              TextButton(
                child: Text(
                  "OK",
                  style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    fontSize: Responsive.isMobileSmall(context)
                        ? 11.5
                        : Responsive.isMobileMedium(context) ||
                                Responsive.isMobileLarge(context)
                            ? 13
                            : Responsive.isTabletPortrait(context)
                                ? 18
                                : 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: TextButton.styleFrom(
                    // backgroundColor: Colors.blue[900],
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize: Size(double.infinity, 40)),
                onPressed: () {
                  okHandler();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
