import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum SignViewState { initial, loading, success, error }

class SignViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  SignViewState _state = SignViewState.initial;
  String _phoneNumber = '';
  String _errorMessage = '';
  UserModel? _user;
  bool _isSignUp = true; // true for sign up, false for sign in

  // Getters
  SignViewState get state => _state;
  String get phoneNumber => _phoneNumber;
  String get errorMessage => _errorMessage;
  UserModel? get user => _user;
  bool get isSignUp => _isSignUp;
  bool get isLoading => _state == SignViewState.loading;
  bool get canContinue => _phoneNumber.length == 10;

  // Setters
  void setPhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  void toggleSignMode() {
    _isSignUp = !_isSignUp;
    _clearError();
    notifyListeners();
  }

  void _setState(SignViewState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(SignViewState.error);
  }

  void _clearError() {
    _errorMessage = '';
    if (_state == SignViewState.error) {
      _setState(SignViewState.initial);
    }
  }

  // Validate phone number
  bool validatePhoneNumber() {
    if (_phoneNumber.isEmpty) {
      _setError('Please enter your mobile number');
      return false;
    }

    if (_phoneNumber.length != 10) {
      _setError('Please enter a valid 10-digit mobile number');
      return false;
    }

    if (!_authService.isValidPhoneNumber(_phoneNumber)) {
      _setError('Please enter a valid Indian mobile number');
      return false;
    }

    return true;
  }

  // Handle continue button press
  Future<void> handleContinue() async {
    if (!validatePhoneNumber()) {
      return;
    }

    _setState(SignViewState.loading);

    try {
      if (_isSignUp) {
        await _handleSignUp();
      } else {
        await _handleSignIn();
      }
    } catch (e) {
      _setError('Something went wrong. Please try again.');
    }
  }

  // Handle sign up
  Future<void> _handleSignUp() async {
    try {
      final user = await _authService.signUp(_phoneNumber);
      _user = user;
      
      // Save a mock token
      await _authService.saveToken('mock_token_${user.id}');
      
      _setState(SignViewState.success);
    } catch (e) {
      _setError('Failed to create account. Please try again.');
    }
  }

  // Handle sign in
  Future<void> _handleSignIn() async {
    try {
      final user = await _authService.signIn(_phoneNumber);
      
      if (user != null) {
        _user = user;
        await _authService.saveToken('mock_token_${user.id}');
        _setState(SignViewState.success);
      } else {
        _setError('No account found with this number. Please sign up first.');
      }
    } catch (e) {
      _setError('Failed to sign in. Please try again.');
    }
  }

  // Reset view model state
  void reset() {
    _state = SignViewState.initial;
    _phoneNumber = '';
    _errorMessage = '';
    _user = null;
    notifyListeners();
  }

  // Clear phone number
  void clearPhoneNumber() {
    _phoneNumber = '';
    _clearError();
    notifyListeners();
  }
} 