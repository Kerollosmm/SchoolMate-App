import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final bool isActive;
  final List<String> assignedGrades;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    required this.assignedGrades,
  });

  @override
  List<Object?> get props => [id, email, name, role, isActive, assignedGrades];
}
