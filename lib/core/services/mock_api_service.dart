import 'dart:async';
import 'dart:math';

class MockApiService {
  final Random _random = Random();

  Future<Map<String, dynamic>> requestOTP({
    required String method,
    required String value,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'requestId': 'mock_request_${DateTime.now().millisecondsSinceEpoch}',
      'expiresInSeconds': 300,
    };
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String requestId,
    required String otpCode,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': 'user_123',
        'name': 'Test User',
        'phone': '+251911234567',
        'email': 'test@example.com',
      }
    };
  }

  Future<List<Map<String, dynamic>>> getNearbyEdir({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    // Sample Edir groups data
    return [
      {
        'id': 'edir_1',
        'name': 'Sefere Selam Edir - ሰፈረ ሰላም እድር',
        'description':
            'A Community-based mutual support group rooted in solidarity and shared responsibility It brings members together to provide financial and social support during times of need, especially in moments of loss.',
        'distanceKm': _random.nextDouble() * 5 + 1,
        'baseContribution': 9,
        'membersCount': 45,
        'maxMembers': 100,
        'frequency': 'Monthly',
        'requirementsSummary': 'Valid ID, Monthly contribution',
        'pricingOverrides': null,
      },
      {
        'id': 'edir_2',
        'name': 'Hibret Fre Edir - ህብረት ፍሬ እድር',
        'description':
            'is a community-driven mutual aid group built on unity and cooperation. It supports members through shared contributions, offering financial and social assistance in times of need.',
        'distanceKm': _random.nextDouble() * 5 + 1.5,
        'baseContribution': 12,
        'membersCount': 32,
        'maxMembers': 50,
        'frequency': 'Monthly',
        'requirementsSummary': 'Referral required',
        'pricingOverrides': {
          'single': 12,
          'couple': 18,
          'child': 6,
          'elderly': 18,
          'adult': 12,
        },
      },
      {
        'id': 'edir_3',
        'name': 'Abima Edir - አብማ እድር',
        'description':
            'is a community-based mutual support association founded on solidarity and care. It brings members together to provide collective financial and social assistance during difficult times.',
        'distanceKm': _random.nextDouble() * 5 + 2,
        'baseContribution': 8,
        'membersCount': 28,
        'maxMembers': 75,
        'frequency': 'Monthly',
        'requirementsSummary': 'Age 18-35, Employed',
        'pricingOverrides': {
          'single': 8,
          'couple': 12,
          'child': 4,
          'elderly': 12,
        },
      },
      {
        'id': 'edir_4',
        'name': 'Menkorer Edir - መንቆረር እድር',
        'description':
            'Local neighborhood fund for emergency support and community projects.',
        'distanceKm': _random.nextDouble() * 5 + 0.5,
        'baseContribution': 10,
        'membersCount': 60,
        'maxMembers': 120,
        'frequency': 'Monthly',
        'requirementsSummary': 'Local resident',
        'pricingOverrides': {
          'single': 10,
          'couple': 16,
          'child': 5,
          'elderly': 20,
        },
      },
      {
        'id': 'edir_5',
        'name': 'Edemaryam Edir- እደማርያም እድር',
        'description':
            'For entrepreneurs and business owners to support each others ventures.',
        'distanceKm': _random.nextDouble() * 5 + 3,
        'baseContribution': 15,
        'membersCount': 22,
        'maxMembers': 40,
        'frequency': 'Monthly',
        'requirementsSummary': 'Business owner, Minimum 1 year operation',
        'pricingOverrides': null,
      },
    ];
  }

  Future<Map<String, dynamic>> getEdirDetails(String edirId) async {
    await Future.delayed(const Duration(seconds: 1));

    final edir = (await getNearbyEdir(lat: 0, lng: 0))
        .firstWhere((edir) => edir['id'] == edirId, orElse: () => {});

    return edir;
  }

  Future<Map<String, dynamic>> calculateContribution({
    required String edirId,
    required String planType,
    required List<Map<String, dynamic>> dependents,
    bool extendedFamilyCoverage = false,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Get edir pricing overrides
    final edir = await getEdirDetails(edirId);
    final overrides = edir['pricingOverrides'];

    // Calculate using default or overridden rates
    final rates = _getRates(overrides);

    // Use null-aware operators with defaults
    double base =
        planType == 'single' ? rates['single'] ?? 9.0 : rates['couple'] ?? 15.0;

    double childrenTotal = 0;
    double elderlyTotal = 0;
    double extendedTotal = 0;

    for (var dependent in dependents) {
      final age = dependent['age'] as int? ?? 0;
      final relation = dependent['relation'] as String? ?? '';

      if (relation == 'child' && age < 18) {
        childrenTotal += rates['child'] ?? 5.0;
      } else if (age > 60) {
        elderlyTotal += rates['elderly'] ?? 15.0;
      } else if (extendedFamilyCoverage && relation == 'other') {
        extendedTotal += rates['adult'] ?? 9.0;
      }
    }

    final total = base + childrenTotal + elderlyTotal + extendedTotal;

    return {
      'breakdown': {
        'base': base,
        'children': childrenTotal,
        'elderly': elderlyTotal,
        'extended': extendedTotal,
      },
      'total': total,
    };
  }

  Map<String, double> _getRates(Map<String, dynamic>? overrides) {
    if (overrides != null) {
      return {
        'single': (overrides['single'] ?? 9).toDouble(),
        'couple': (overrides['couple'] ?? 15).toDouble(),
        'child': (overrides['child'] ?? 5).toDouble(),
        'elderly': (overrides['elderly'] ?? 15).toDouble(),
        'adult': (overrides['adult'] ?? 9).toDouble(),
      };
    }

    return {
      'single': 9.0,
      'couple': 15.0,
      'child': 5.0,
      'elderly': 15.0,
      'adult': 9.0,
    };
  }

  Future<Map<String, dynamic>> submitJoinRequest({
    required String edirId,
    required Map<String, dynamic> application,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    return {
      'status': 'submitted',
      'membershipId': 'member_${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Your application has been submitted for review',
      'submittedAt': DateTime.now().toIso8601String(),
    };
  }
  // Add to MockApiService class

  Future<List<Map<String, dynamic>>> getUserContributions(String userId) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock contribution data
    return [
      {
        'id': 'contrib_1',
        'groupId': 'edir_1',
        'userId': userId,
        'amount': 25.0,
        'date':
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'note': 'Monthly contribution - January',
        'status': 'completed',
        'transactionId': 'txn_123',
      },
      {
        'id': 'contrib_2',
        'groupId': 'edir_1',
        'userId': userId,
        'amount': 25.0,
        'date':
            DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'note': 'Monthly contribution - December',
        'status': 'completed',
        'transactionId': 'txn_124',
      },
      {
        'id': 'contrib_3',
        'groupId': 'edir_1',
        'userId': userId,
        'amount': 25.0,
        'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'note': 'Upcoming February contribution',
        'status': 'pending',
        'transactionId': null,
      },
    ];
  }

  Future<Map<String, dynamic>> recordContribution({
    required String groupId,
    required String userId,
    required double amount,
    required String note,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'id': 'contrib_${DateTime.now().millisecondsSinceEpoch}',
      'groupId': groupId,
      'userId': userId,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
      'note': note,
      'status': 'completed',
      'transactionId': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Contribution recorded successfully',
    };
  }

  Future<List<Map<String, dynamic>>> getSupportRequests(String userId) async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      {
        'id': 'req_1',
        'groupId': 'edir_1',
        'requesterId': userId,
        'amountRequested': 50000.0,
        'reason': 'Medical emergency - Hospital bills',
        'status': 'approved',
        'requestedAt':
            DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        'reviewedAt':
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'notes': 'Approved by committee',
      },
      {
        'id': 'req_2',
        'groupId': 'edir_1',
        'requesterId': userId,
        'amountRequested': 30000.0,
        'reason': 'School fees for children',
        'status': 'pending',
        'requestedAt':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'reviewedAt': null,
        'notes': null,
      },
      {
        'id': 'req_3',
        'groupId': 'edir_1',
        'requesterId': 'user_456', // Another user
        'amountRequested': 40000.0,
        'reason': 'Business capital',
        'status': 'pending',
        'requestedAt':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'reviewedAt': null,
        'notes': null,
      },
    ];
  }

  Future<Map<String, dynamic>> submitSupportRequest({
    required String groupId,
    required String userId,
    required double amountRequested,
    required String reason,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'id': 'req_${DateTime.now().millisecondsSinceEpoch}',
      'groupId': groupId,
      'requesterId': userId,
      'amountRequested': amountRequested,
      'reason': reason,
      'status': 'pending',
      'requestedAt': DateTime.now().toIso8601String(),
      'message': 'Support request submitted successfully',
    };
  }

  Future<Map<String, dynamic>> reviewSupportRequest({
    required String requestId,
    required bool approve,
    String? notes,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'requestId': requestId,
      'status': approve ? 'approved' : 'denied',
      'reviewedAt': DateTime.now().toIso8601String(),
      'notes': notes,
      'message': 'Support request ${approve ? 'approved' : 'denied'}',
    };
  }
  // Admin Dashboard Methods

  Future<Map<String, dynamic>> getAdminStats(String adminId) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'totalMembers': 156,
      'totalEdirs': 12,
      'pendingApplications': 8,
      'pendingSupportRequests': 15,
      'totalContributions': 1250000,
      'totalDisbursed': 850000,
      'activeMembers': 142,
      'overduePayments': 14,
      'monthlyGrowth': 12.5,
      'satisfactionRate': 94.3,
    };
  }

  Future<List<Map<String, dynamic>>> getPendingApplications(
      String adminId) async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      {
        'id': 'app_1',
        'userId': 'user_100',
        'edirId': 'edir_1',
        'edirName': 'Sefere Selam Edir - ሰፈረ ሰላም እድር',
        'userName': 'Alemayehu Kebede',
        'userPhone': '+251911223344',
        'appliedAt':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'status': 'pending',
        'requestedAmount': 25,
        'householdDetails': {
          'planType': 'couple',
          'spouseName': 'Marta Alemayehu',
          'dependents': [
            {'name': 'Sofia', 'age': 12, 'relation': 'child'},
            {'name': 'Daniel', 'age': 8, 'relation': 'child'},
          ],
          'extendedFamilyCoverage': false,
        },
      },
      {
        'id': 'app_2',
        'userId': 'user_101',
        'edirId': 'edir_2',
        'edirName': 'Hibret Fre Edir - ህብረት ፍሬ እድር',
        'userName': 'Tigist Hailu',
        'userPhone': '+251922334455',
        'appliedAt':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'status': 'pending',
        'requestedAmount': 12,
        'householdDetails': {
          'planType': 'single',
          'dependents': [],
          'extendedFamilyCoverage': true,
        },
      },
      {
        'id': 'app_3',
        'userId': 'user_102',
        'edirId': 'edir_1',
        'edirName': 'Sefere Selam Edir - ሰፈረ ሰላም እድር',
        'userName': 'Samuel Bekele',
        'userPhone': '+251933445566',
        'appliedAt':
            DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'status': 'pending',
        'requestedAmount': 29,
        'householdDetails': {
          'planType': 'single',
          'dependents': [
            {'name': 'Elder Kebede', 'age': 65, 'relation': 'elder'},
          ],
          'extendedFamilyCoverage': false,
        },
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getAllEdirs() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      {
        'id': 'edir_1',
        'name': 'Sefere Selam Edir - ሰፈረ ሰላም እድር',
        'description': 'A community-based financial support group',
        'baseContribution': 9,
        'frequency': 'Monthly',
        'membersCount': 45,
        'maxMembers': 100,
        'status': 'active',
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 365))
            .toIso8601String(),
        'adminId': 'admin_1',
        'totalFunds': 450000,
        'meetingDay': '15th of each month',
      },
      {
        'id': 'edir_2',
        'name': 'Hibret Fre Edir - ህብረት ፍሬ እድር',
        'description': 'Focused on family welfare and education',
        'baseContribution': 12,
        'frequency': 'Monthly',
        'membersCount': 32,
        'maxMembers': 50,
        'status': 'active',
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 180))
            .toIso8601String(),
        'adminId': 'admin_2',
        'totalFunds': 320000,
        'meetingDay': '10th of each month',
      },
      {
        'id': 'edir_3',
        'name': 'Abima Edir - አብማ እድር',
        'description': 'Empowering young professionals',
        'baseContribution': 8,
        'frequency': 'Monthly',
        'membersCount': 28,
        'maxMembers': 75,
        'status': 'active',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
        'adminId': 'admin_3',
        'totalFunds': 200000,
        'meetingDay': '5th of each month',
      },
      {
        'id': 'edir_4',
        'name': 'Pending Approval Edir',
        'description': 'New group awaiting approval',
        'baseContribution': 10,
        'frequency': 'Monthly',
        'membersCount': 5,
        'maxMembers': 50,
        'status': 'pending',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'adminId': 'user_50',
        'totalFunds': 50000,
        'meetingDay': '20th of each month',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getAllMembers() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      {
        'id': 'user_100',
        'name': 'Alemayehu Kebede',
        'email': 'alemu@example.com',
        'phone': '+251911223344',
        'role': 'member',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'isActive': true,
        'profileImage': null,
        'groupIds': ['edir_1'],
        'lastContribution':
            DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        'totalContributions': 25000,
        'supportRequests': 1,
      },
      {
        'id': 'user_101',
        'name': 'Tigist Hailu',
        'email': 'tigist@example.com',
        'phone': '+251922334455',
        'role': 'member',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
        'isActive': true,
        'profileImage': null,
        'groupIds': ['edir_2'],
        'lastContribution':
            DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        'totalContributions': 18000,
        'supportRequests': 0,
      },
      {
        'id': 'user_102',
        'name': 'Samuel Bekele',
        'email': 'samuel@example.com',
        'phone': '+251933445566',
        'role': 'member',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'isActive': true,
        'profileImage': null,
        'groupIds': ['edir_1', 'edir_3'],
        'lastContribution':
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'totalContributions': 45000,
        'supportRequests': 2,
      },
      {
        'id': 'user_103',
        'name': 'Marta Alemayehu',
        'email': 'marta@example.com',
        'phone': '+251944556677',
        'role': 'member',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
        'isActive': false,
        'profileImage': null,
        'groupIds': ['edir_1'],
        'lastContribution': DateTime.now()
            .subtract(const Duration(days: 120))
            .toIso8601String(),
        'totalContributions': 15000,
        'supportRequests': 1,
      },
    ];
  }

  Future<Map<String, dynamic>> reviewApplication({
    required String applicationId,
    required bool approve,
    String? notes,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'applicationId': applicationId,
      'status': approve ? 'approved' : 'rejected',
      'reviewedAt': DateTime.now().toIso8601String(),
      'notes': notes,
      'message':
          'Application ${approve ? 'approved' : 'rejected'} successfully',
    };
  }

  Future<Map<String, dynamic>> createEdir({
    required String name,
    required String description,
    required double baseContribution,
    required String frequency,
    required int maxMembers,
    required String adminId,
    String? meetingDay,
    Map<String, dynamic>? pricingOverrides,
    List<String>? requirements,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'id': 'edir_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'description': description,
      'baseContribution': baseContribution,
      'frequency': frequency,
      'membersCount': 1, // Admin is first member
      'maxMembers': maxMembers,
      'status': 'pending', // New Edirs need approval
      'createdAt': DateTime.now().toIso8601String(),
      'adminId': adminId,
      'meetingDay': meetingDay ?? '1st of each month',
      'pricingOverrides': pricingOverrides,
      'requirements': requirements ?? ['Valid ID', 'Monthly contribution'],
      'message': 'Edir created successfully and submitted for approval',
    };
  }

  Future<Map<String, dynamic>> updateEdirStatus({
    required String edirId,
    required String status, // 'active', 'suspended', 'closed'
    String? reason,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'edirId': edirId,
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
      'reason': reason,
      'message': 'Edir status updated to $status',
    };
  }

  Future<Map<String, dynamic>> updateMemberStatus({
    required String userId,
    required bool isActive,
    String? reason,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'userId': userId,
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
      'reason': reason,
      'message':
          'Member ${isActive ? 'activated' : 'deactivated'} successfully',
    };
  }
}
