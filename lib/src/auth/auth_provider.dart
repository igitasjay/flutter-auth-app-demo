import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_auth_flow_app/src/database/db_provider.dart';
import 'package:http/http.dart' as http;

class AuthenticationProvider extends ChangeNotifier {
  // BASE URL
  final String requestBaseUrl = "AppConstants.baseUrl";

  // final dio = Dio();

  // SETTER
  bool _isLoading = false;
  String _resMessage = '';

  // GETTER
  bool get isLoading => _isLoading;
  String get resMessage => _resMessage;

  // REGISTER USER
  void registerUser({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    bool? isChecked,
    BuildContext? context,
  }) async {
    _isLoading = true;
    notifyListeners();

    if (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
        .hasMatch(phoneNumber)) {
      _resMessage = 'Enter a valid phone number';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(email)) {
      _resMessage = 'Email must be valid';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (password.length < 5 || password.length > 12) {
      _resMessage = 'Password must be between 6 to 12 characters long';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (fullName.trim().split(' ').length < 2) {
      _resMessage = 'Full name must contain at least two names';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (isChecked == false) {
      _resMessage = 'You must agree to our terms of use and policy';
      _isLoading = false;
      notifyListeners();
    }

    String url = '$requestBaseUrl/api/v1/auth/register';

    final body = {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
    };
    print(body);

    try {
      http.Response req = await http.post(
        Uri.parse(url),
        body: body,
      );
      if (req.statusCode == 200 || req.statusCode == 201) {
        // final res = json.decode(req.body);
        print('......$req');
        print(">>>>>${req.body}");
        _isLoading = false;
        _resMessage = 'Account created';

        notifyListeners();

        // PageNavigator(context: context).nextPageOnly(
        //   page: const VerificationPage(),
        // );
      } else {
        final res = json.decode(req.body);
        _resMessage = (res['message'] ?? '').toString();
        print(res);
        print(_resMessage);
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      print(",,,,,,,$_");
      _isLoading = true;
      _resMessage = 'No or bad internet connection';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print(':::: $e');
      // print('::::: $')
      _isLoading = false;
      _resMessage = 'An internal error occured';
      notifyListeners();
    }
  }

  // VERIFY PHONE NUMBER

  // IMPLEMENT INITIALIZE-VERIFICATION
  // Future<Map<String, dynamic>> initializeVerification(
  //     {required String authorization}) async {
  //   final response = await dio.post(
  //     '$requestBaseUrl/api/v1/auth/initialize-verification',
  //     options: Options(
  //       headers: {
  //         'authorization': "",
  //       },
  //     ),
  //   );

  //   return response.data;
  // }

  // IMPLEMENT COMPLETE-VERIFICATION
  // Future<Map<String, dynamic>> completeVerification({
  //   required String authorization,
  //   required String code,
  // }) async {
  //   final response = await dio.post(
  //     '$requestBaseUrl/api/v1/auth/complete-verification',
  //     options: Options(
  //       headers: {
  //         'authorization': authorization,
  //       },
  //     ),
  //     data: {
  //       'code': code,
  //     },
  //   );

  //   return response.data;
  // }

  // LOG IN USER
  void loginUser({
    required String email,
    required String password,
    BuildContext? context,
  }) async {
    _isLoading = true;
    notifyListeners();

    String url = '$requestBaseUrl/api/v1/auth/login';

    final body = {
      'email': email,
      'password': password,
    };
    print(body);

    try {
      http.Response req = await http.post(
        Uri.parse(url),
        body: body,
      );
      if (req.statusCode == 200 || req.statusCode == 201) {
        print(req.body);
        final res = json.decode(req.body);
        print(res);
        // PageNavigator(context: context).nextPageOnly(
        //   page: const CleanPage(),
        // );

        // Add null checks before assigning the values to variables
        final userId = res['user'] != null ? res['user']['id'] : null;
        final token = res['authToken'];

        if (userId != null && token != null) {
          _isLoading = false;
          _resMessage = 'Login successful';
          notifyListeners();

          // ADD USER TO DATABASE
          DatabaseProvider().saveToken(token);
          DatabaseProvider().saveUserId(userId);
          // PageNavigator(context: context).nextPageOnly(
          //   page: const HomePage(),
          // );
        } else {
          _resMessage = 'User ID or auth token is null in the response';
          _isLoading = false;
          notifyListeners();
        }
      } else {
        final res = json.decode(req.body);
        _resMessage = (res['message'] ?? '').toString();
        print(res);
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      print(_);
      _isLoading = true;
      _resMessage = 'Internet connection is not available';
      notifyListeners();
    } catch (e) {
      print(':::: $e');
      _isLoading = false;
      _resMessage = 'An internal error occurred';
      notifyListeners();
    }
  }

  void clear() {
    _resMessage = '';
    notifyListeners();
  }
}
