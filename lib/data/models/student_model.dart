import 'package:hive/hive.dart';
import '../../domain/entities/student.dart';

part 'student_model.g.dart';

@HiveType(typeId: 1)
class StudentModel extends Student {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String grade;
  @HiveField(3)
  final String? assignedServantId;

  const StudentModel({
    required this.id,
    required this.name,
    required this.grade,
    this.assignedServantId,
  }) : super(
          id: id,
          name: name,
          grade: grade,
          assignedServantId: assignedServantId,
        );

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      grade: json['grade'] ?? '',
      assignedServantId: json['assignedServantId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'assignedServantId': assignedServantId,
    };
  }

    factory StudentModel.fromEntity(Student entity) {
    return StudentModel(
      id: entity.id,
      name: entity.name,
      grade: entity.grade,
      assignedServantId: entity.assignedServantId,
    );
  }
}
