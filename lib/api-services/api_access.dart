import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static final String apiBaseUrl =
      'http://auradocs-kyc.southindia.cloudapp.azure.com/';

  static Future<dynamic> loginUser(String username, String password) async {
    try {
      var url = Uri.parse('${apiBaseUrl}live/mobile/login');
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "username": username,
          "password": password,
        }),
      );

      return response;
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  static Future<dynamic> registerUser(
      String email,
      String password,
      String firstName,
      String lastName,
      String fileName,
      String fileMimeType,
      String fileBase64) async {
    try {
      var url = Uri.parse('${apiBaseUrl}live/mobile/register');
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "email": email,
          "password": password,
          "firstName": firstName,
          "lastName": lastName,
          "profilePicture": {
            "fileName": fileName,
            "fileMimeType": fileMimeType,
            "fileBase64": fileBase64
          },
        }),
      );

      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static dynamic getDetailsOfSubmission(String token) async {
    try {
      var url = Uri.parse('${apiBaseUrl}live/mobile/kyc-user/get-request');

      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token", // Use retrieved token
        },
      );

      return response;
    } catch (e) {
      print(e);
    }
  }

  static dynamic getProfileDetails(String token) async {
    try {
      var url = Uri.parse('${apiBaseUrl}live/mobile/profile');

      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token", // Use retrieved token
        },
      );

      return response;
    } catch (e) {
      print(e);
    }
  }

  static dynamic getAllowedNotAllowedBanks(String token, bool isAllowed) async {
    try {
      var url = Uri.parse(
          '${apiBaseUrl}live/mobile/get-financial-institute/$isAllowed');

      var response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token", // Use retrieved token
        },
      );

      return response;
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> changeAllowedRequest(
      String token, String kycProfileId, int bankId) async {
    try {
      var url = Uri.parse('${apiBaseUrl}live/mobile/change-fi-request');
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Use retrieved token
        },
        body: json.encode({"kycProfileId": kycProfileId, "bankId": bankId}),
      );

      return response;
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }
}
