import 'package:hive/hive.dart';
import '../../core/constants/enums.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 0)
class UserProfileModel extends UserProfile {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String roleString; // Store enum as string for simplicity in JSON/Hive if needed, or use Enum adapter
  @HiveField(4)
  final bool isActive;
  @HiveField(5)
  final List<String> assignedGrades;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.name,
    required this.roleString,
    required this.isActive,
    required this.assignedGrades,
  }) : super(
          id: id,
          email: email,
          name: name,
          role: roleString == 'admin' ? UserRole.admin : UserRole.servant,
          isActive: isActive,
          assignedGrades: assignedGrades,
        );

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      roleString: json['role'] ?? 'servant',
      isActive: json['isActive'] ?? true,
      assignedGrades: List<String>.from(json['assignedGrades'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'email': email,
      'name': name,
      'role': roleString,
      'isActive': isActive,
      'assignedGrades': assignedGrades,
    };
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      roleString: entity.role == UserRole.admin ? 'admin' : 'servant',
      isActive: entity.isActive,
      assignedGrades: entity.assignedGrades,
    );
  }
}
