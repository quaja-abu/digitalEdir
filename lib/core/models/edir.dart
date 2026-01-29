class Edir {
  final String id;
  final String name;
  final String description;
  final double baseContribution;
  final String frequency;
  final int membersCount;
  final int maxMembers;
  final Map<String, dynamic>? pricingOverrides;
  final List<String> requirements;
  final double? distanceKm;
  final String? status;
  final DateTime? createdAt;
  final String? adminId;
  final double? totalFunds;
  final String? meetingDay;

  Edir({
    required this.id,
    required this.name,
    required this.description,
    required this.baseContribution,
    required this.frequency,
    required this.membersCount,
    required this.maxMembers,
    this.pricingOverrides,
    this.requirements = const [],
    this.distanceKm,
    this.status = 'active',
    this.createdAt,
    this.adminId,
    this.totalFunds,
    this.meetingDay,
  });

  Edir copyWith({
    String? status,
  }) {
    return Edir(
      id: id,
      name: name,
      description: description,
      baseContribution: baseContribution,
      frequency: frequency,
      membersCount: membersCount,
      maxMembers: maxMembers,
      pricingOverrides: pricingOverrides,
      requirements: requirements,
      distanceKm: distanceKm,
      status: status ?? this.status,
      createdAt: createdAt,
      adminId: adminId,
      totalFunds: totalFunds,
      meetingDay: meetingDay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'baseContribution': baseContribution,
      'frequency': frequency,
      'membersCount': membersCount,
      'maxMembers': maxMembers,
      'pricingOverrides': pricingOverrides,
      'requirements': requirements,
      'distanceKm': distanceKm,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'adminId': adminId,
      'totalFunds': totalFunds,
      'meetingDay': meetingDay,
    };
  }

  factory Edir.fromJson(Map<String, dynamic> json) {
    return Edir(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      baseContribution: (json['baseContribution'] ?? 0).toDouble(),
      frequency: json['frequency'],
      membersCount: json['membersCount'] ?? 0,
      maxMembers: json['maxMembers'] ?? 0,
      pricingOverrides: json['pricingOverrides'] != null
          ? Map<String, dynamic>.from(json['pricingOverrides'])
          : null,
      requirements: List<String>.from(json['requirements'] ?? []),
      distanceKm: json['distanceKm']?.toDouble(),
      status: json['status'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      adminId: json['adminId'],
      totalFunds: json['totalFunds']?.toDouble(),
      meetingDay: json['meetingDay'],
    );
  }
}
