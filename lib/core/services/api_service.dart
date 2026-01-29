import 'dart:convert';
import 'package:digitaledir/core/services/http_service.dart';
import 'package:digitaledir/core/services/storage_service.dart';
import 'package:digitaledir/core/config/environment.dart';
import 'package:digitaledir/core/models/user.dart';
import 'package:digitaledir/core/models/edir.dart';
import 'package:digitaledir/core/models/contribution.dart';
import 'package:digitaledir/core/models/support_request.dart';
import 'package:digitaledir/core/models/admin_dashboard.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final HttpService _httpService = HttpService();
  final StorageService _storageService = StorageService();

  // ========== AUTHENTICATION ==========

  Future<Map<String, dynamic>> requestOTP({
    required String method,
    required String value,
  }) async {
    try {
      final response = await _httpService.post(
        EnvironmentConfig.authRequestOtp,
        data: {
          'method': method,
          'value': value,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String requestId,
    required String otpCode,
    bool isAdmin = false,
  }) async {
    try {
      final response = await _httpService.post(
        EnvironmentConfig.authVerifyOtp,
        data: {
          'requestId': requestId,
          'otpCode': otpCode,
          'isAdmin': isAdmin,
        },
      );

      final data = response.data;

      // Store tokens
      if (data['token'] != null) {
        await _storageService.setAuthToken(data['token']);
      }
      if (data['refreshToken'] != null) {
        await _storageService.setRefreshToken(data['refreshToken']);
      }

      // Store user data
      if (data['user'] != null) {
        await _storageService.setUserData(data['user']);
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _httpService.post(EnvironmentConfig.authLogout);
    } finally {
      // Always clear local storage
      await _storageService.clearAuthTokens();
      await _storageService.clearUserData();
      _httpService.clearAuthHeader();
    }
  }

  // ========== EDIR GROUPS ==========

  Future<List<Edir>> getNearbyEdir({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    try {
      final response = await _httpService.get(
        EnvironmentConfig.edirNearby,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radiusKm': radiusKm,
        },
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Edir.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Edir>> searchEdir(String query) async {
    try {
      final response = await _httpService.get(
        EnvironmentConfig.edirSearch,
        queryParameters: {'q': query},
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Edir.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Edir> getEdirDetails(String edirId) async {
    try {
      final response = await _httpService.get(
        EnvironmentConfig.edirDetails.replaceAll(':id', edirId),
      );

      return Edir.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createEdir({
    required String name,
    required String description,
    required double baseContribution,
    required String frequency,
    required int maxMembers,
    String? meetingDay,
    Map<String, dynamic>? pricingOverrides,
    List<String>? requirements,
  }) async {
    try {
      final response = await _httpService.post(
        EnvironmentConfig.edirCreate,
        data: {
          'name': name,
          'description': description,
          'baseContribution': baseContribution,
          'frequency': frequency,
          'maxMembers': maxMembers,
          'meetingDay': meetingDay,
          'pricingOverrides': pricingOverrides,
          'requirements': requirements,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ========== CONTRIBUTIONS ==========

  Future<List<Contribution>> getUserContributions({
    String? userId,
    String? edirId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) queryParams['userId'] = userId;
      if (edirId != null) queryParams['edirId'] = edirId;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _httpService.get(
        EnvironmentConfig.contributionsList,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Contribution.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> recordContribution({
    required String edirId,
    required double amount,
    required String note,
    String? paymentMethod,
    String? transactionId,
  }) async {
    try {
      final response = await _httpService.post(
        EnvironmentConfig.contributionsCreate,
        data: {
          'edirId': edirId,
          'amount': amount,
          'note': note,
          'paymentMethod': paymentMethod,
          'transactionId': transactionId,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getContributionStats(String userId) async {
    try {
      final response = await _httpService.get(
        EnvironmentConfig.contributionsStats,
        queryParameters: {'userId': userId},
      );

      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  // ========== SUPPORT REQUESTS ==========

  Future<List<SupportRequest>> getSupportRequests({
    String? userId,
    String? edirId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) queryParams['userId'] = userId;
      if (edirId != null) queryParams['edirId'] = edirId;
      if (status != null) queryParams['status'] = status;

      final response = await _httpService.get(
        EnvironmentConfig.supportRequestsList,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => SupportRequest.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitSupportRequest({
    required String edirId,
    required double amountRequested,
    required String reason,
    String? category,
    String? details,
  }) async {
    try {
      final response = await _httpService.post(
        EnvironmentConfig.supportRequestsCreate,
        data: {
          'edirId': edirId,
          'amountRequested': amountRequested,
          'reason': reason,
          'category': category,
          'details': details,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> reviewSupportRequest({
    required String requestId,
    required bool approve,
    String? notes,
  }) async {
    try {
      final response = await _httpService.post(
        EnvironmentConfig.supportRequestsReview.replaceAll(':id', requestId),
        data: {
          'approve': approve,
          'notes': notes,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ========== MEMBERSHIP ==========

  Future<Map<String, dynamic>> calculateContribution({
    required String edirId,
    required String planType,
    required List<Map<String, dynamic>> dependents,
    bool extendedFamilyCoverage = false,
  }) async {
    try {
      final response = await _httpService.post(
        '/edir/$edirId/calculate-contribution',
        data: {
          'planType': planType,
          'dependents': dependents,
          'extendedFamilyCoverage': extendedFamilyCoverage,
        },
      );

      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitJoinRequest({
    required String edirId,
    required Map<String, dynamic> application,
  }) async {
    try {
      final response = await _httpService.post(
        '/edir/$edirId/join',
        data: application,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ========== ADMIN ENDPOINTS ==========

  Future<AdminStats> getAdminStats() async {
    try {
      final response = await _httpService.get(EnvironmentConfig.adminStats);
      return AdminStats.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MemberApplication>> getPendingApplications() async {
    try {
      final response =
          await _httpService.get(EnvironmentConfig.memberApplications);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => MemberApplication.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getAllMembers({
    String? search,
    bool? active,
    String? role,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (active != null) queryParams['active'] = active;
      if (role != null) queryParams['role'] = role;

      final response = await _httpService.get(
        EnvironmentConfig.memberList,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Edir>> getAllEdirs({
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;

      final response = await _httpService.get(
        EnvironmentConfig.edirList,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Edir.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> reviewApplication({
    required String applicationId,
    required bool approve,
    String? notes,
  }) async {
    try {
      final response = await _httpService.post(
        EnvironmentConfig.memberApplicationReview
            .replaceAll(':id', applicationId),
        data: {
          'approve': approve,
          'notes': notes,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateMemberStatus({
    required String userId,
    required bool isActive,
    String? reason,
  }) async {
    try {
      final response = await _httpService.patch(
        '${EnvironmentConfig.memberDetails.replaceAll(':id', userId)}/status',
        data: {
          'isActive': isActive,
          'reason': reason,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateEdirStatus({
    required String edirId,
    required String status,
    String? reason,
  }) async {
    try {
      final response = await _httpService.patch(
        '${EnvironmentConfig.edirDetails.replaceAll(':id', edirId)}/status',
        data: {
          'status': status,
          'reason': reason,
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  // Add to ApiService class

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _httpService.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;

      // Store new tokens
      if (data['token'] != null) {
        await _storageService.setAuthToken(data['token']);
      }
      if (data['refreshToken'] != null) {
        await _storageService.setRefreshToken(data['refreshToken']);
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await _httpService.get(
        '/auth/verify-token',
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    String token,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _httpService.put(
        '/users/profile',
        data: updates,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _httpService.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
