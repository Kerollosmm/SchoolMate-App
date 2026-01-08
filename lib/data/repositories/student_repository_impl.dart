import 'package:uuid/uuid.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/local/hive_service.dart';
import '../datasources/remote/firestore_service.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final HiveService _hiveService;
  final FirestoreService _firestoreService;

  StudentRepositoryImpl({
    required HiveService hiveService,
    required FirestoreService firestoreService,
  })  : _hiveService = hiveService,
        _firestoreService = firestoreService;

  @override
  Future<List<Student>> getStudents(String? grade) async {
    final all = _hiveService.getAllStudents();
    if (grade != null) {
      return all.where((s) => s.grade == grade).toList();
    }
    return all;
  }

  @override
  Future<void> addStudent(Student student) async {
    final model = StudentModel.fromEntity(student);
    await _hiveService.saveStudent(model);
    await _firestoreService.saveStudent(model);
  }

  @override
  Future<void> updateStudent(Student student) async {
    final model = StudentModel.fromEntity(student);
    await _hiveService.saveStudent(model);
    await _firestoreService.saveStudent(model);
  }

  @override
  Future<void> deleteStudent(String id) async {
    await _hiveService.deleteStudent(id);
    await _firestoreService.deleteStudent(id);
  }

  @override
  Future<void> importStudents(List<Student> students) async {
    for (var student in students) {
      await addStudent(student);
    }
  }
}
