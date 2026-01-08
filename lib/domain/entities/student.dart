import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String name;
  final String grade;
  final String? assignedServantId;

  const Student({
    required this.id,
    required this.name,
    required this.grade,
    this.assignedServantId,
  });

  @override
  List<Object?> get props => [id, name, grade, assignedServantId];
}
