import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _mobileKey = 'mobile_number';

  // Simulate API call for user registration
  Future<UserModel> signUp(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 2));
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
    );
    await _saveUser(user);
    await saveMobileNumber(phoneNumber);
    return user;
  }

  // Simulate API call for user login
  Future<UserModel?> signIn(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    final user = await _getUser();
    if (user?.phoneNumber == phoneNumber) {
      await saveMobileNumber(phoneNumber);
      return user;
    }
    return null;
  }

  // Save user data to local storage
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Get user data from local storage
  Future<UserModel?> _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Save authentication token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get authentication token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save mobile number
  Future<void> saveMobileNumber(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mobileKey, mobile);
  }

  // Get mobile number
  Future<String?> getMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final mobile = await getMobileNumber();
    return mobile != null && mobile.isNotEmpty;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_mobileKey);
  }

  // Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    return phoneRegex.hasMatch(phoneNumber);
  }
} 