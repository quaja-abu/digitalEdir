import 'dart:async';
import 'package:flutter/material.dart';
import 'package:digitaledir/data/repositories/auth_repository.dart';
import 'package:digitaledir/core/services/storage_service.dart';
import 'package:digitaledir/core/models/user.dart';
import 'package:digitaledir/core/providers/service_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = ServiceProvider.authRepository;
  final StorageService _storageService = ServiceProvider.storageService;

  User? _user;
  String? _token;
  String? _refreshToken;
  bool _isLoading = false;
  Timer? _tokenRefreshTimer;

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isAdmin => _user?.role == 'admin' || _user?.role == 'super_admin';
  bool get isSuperAdmin => _user?.role == 'super_admin';

  String? get userName => _user?.name;
  String? get email => _user?.email;
  String? get phone => _user?.phone;
  String? get role => _user?.role;

  // Initialize provider
  Future<void> initialize() async {
    await _loadStoredAuth();
    _startTokenRefreshTimer();
  }

  // Load stored authentication data
  Future<void> _loadStoredAuth() async {
    try {
      final token = await _storageService.getAuthToken();
      final refreshToken = await _storageService.getRefreshToken();

      if (token != null) {
        _token = token;
        _refreshToken = refreshToken;

        // Load user data from storage
        final userData = await _storageService.getUserData();
        if (userData != null) {
          _user = User.fromJson(userData);
        }

        // Verify token with backend (optional)
        await _verifyToken();

        notifyListeners();
      }
    } catch (e) {
      print('Error loading stored auth: $e');
      await _clearAuth();
    }
  }

  // Request OTP
  Future<Map<String, dynamic>> requestOTP({
    required String method,
    required String value,
  }) async {
    setLoading(true);
    try {
      final result = await _authRepository.requestOTP(
        method: method,
        value: value,
      );
      return result;
    } finally {
      setLoading(false);
    }
  }

  // Verify OTP and login
  Future<void> verifyOTP({
    required String requestId,
    required String otpCode,
    bool isAdmin = false,
  }) async {
    setLoading(true);
    try {
      final result = await _authRepository.verifyOTP(
        requestId: requestId,
        otpCode: otpCode,
        isAdmin: isAdmin,
      );

      // Store tokens
      _token = result['token'];
      _refreshToken = result['refreshToken'];
      _user = User.fromJson(result['user']);

      // Save to storage
      await _storageService.setAuthToken(_token!);
      if (_refreshToken != null) {
        await _storageService.setRefreshToken(_refreshToken!);
      }
      await _storageService.setUserData(_user!.toJson());

      // Start token refresh timer
      _startTokenRefreshTimer();

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Refresh token
  Future<void> refreshToken() async {
    if (_refreshToken == null) {
      await logout();
      return;
    }

    try {
      final result = await _authRepository.refreshToken(_refreshToken!);

      _token = result['token'];
      _refreshToken = result['refreshToken'];

      // Save new tokens
      await _storageService.setAuthToken(_token!);
      if (_refreshToken != null) {
        await _storageService.setRefreshToken(_refreshToken!);
      }

      // Restart timer
      _startTokenRefreshTimer();

      notifyListeners();
    } catch (e) {
      print('Token refresh failed: $e');
      await logout();
    }
  }

  // Verify token with backend
  Future<void> _verifyToken() async {
    try {
      final result = await _authRepository.verifyToken(_token!);
      _user = User.fromJson(result['user']);
      await _storageService.setUserData(_user!.toJson());
      notifyListeners();
    } catch (e) {
      print('Token verification failed: $e');
      // Token might be expired, try to refresh
      await refreshToken();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      if (_token != null) {
        await _authRepository.logout();
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _clearAuth();
      notifyListeners();
    }
  }

  // Clear all auth data
  Future<void> _clearAuth() async {
    _user = null;
    _token = null;
    _refreshToken = null;

    // Stop refresh timer
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;

    // Clear storage
    await _storageService.clearAuthTokens();
    await _storageService.clearUserData();
  }

  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    setLoading(true);
    try {
      final result = await _authRepository.updateProfile(_token!, updates);
      _user = User.fromJson(result['user']);
      await _storageService.setUserData(_user!.toJson());
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  // Change password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    setLoading(true);
    try {
      await _authRepository.changePassword(
        _token!,
        currentPassword,
        newPassword,
      );
    } finally {
      setLoading(false);
    }
  }

  // Token refresh timer
  void _startTokenRefreshTimer() {
    // Cancel existing timer
    _tokenRefreshTimer?.cancel();

    // Set new timer to refresh 5 minutes before expiration
    // Assuming token expires in 1 hour (3600 seconds)
    const refreshBeforeSeconds = 300; // 5 minutes
    const checkIntervalSeconds = 60; // Check every minute

    _tokenRefreshTimer = Timer.periodic(
      const Duration(seconds: checkIntervalSeconds),
      (timer) async {
        // Check if token needs refresh
        // In real implementation, decode JWT to check expiration
        await refreshToken();
      },
    );
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }
}
