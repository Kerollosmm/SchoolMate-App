class ServantProfile {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin' or 'servant'
  final bool isActive;
  final String assignedGrade; // e.g., "Grade 1", or "All" for admin

  ServantProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.assignedGrade,
  });

  factory ServantProfile.fromJson(Map<String, dynamic> json) {
    return ServantProfile(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'servant',
      isActive: json['isActive'] ?? false,
      assignedGrade: json['assignedGrade'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      'assignedGrade': assignedGrade,
    };
  }
}
