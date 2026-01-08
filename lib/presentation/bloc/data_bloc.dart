import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/repositories/attendance_repository.dart';

// Events
abstract class DataEvent extends Equatable {
  const DataEvent();
  @override
  List<Object?> get props => [];
}

class LoadStudents extends DataEvent {
    final String? grade;
    const LoadStudents(this.grade);
}
class AddStudent extends DataEvent {
    final Student student;
    const AddStudent(this.student);
}
class ImportStudents extends DataEvent {}
class ExportAttendance extends DataEvent {
    final DateTime date;
    const ExportAttendance(this.date);
}

// States
abstract class DataState extends Equatable {
  const DataState();
  @override
  List<Object?> get props => [];
}

class DataInitial extends DataState {}
class DataLoading extends DataState {}
class DataLoaded extends DataState {
    final List<Student> students;
    const DataLoaded(this.students);
}
class DataError extends DataState {
    final String message;
    const DataError(this.message);
}
class DataSuccess extends DataState {
    final String message;
    const DataSuccess(this.message);
}

// Bloc
class DataBloc extends Bloc<DataEvent, DataState> {
  final StudentRepository _studentRepository;
  final AttendanceRepository _attendanceRepository;

  DataBloc({
    required StudentRepository studentRepository,
    required AttendanceRepository attendanceRepository,
  })  : _studentRepository = studentRepository,
        _attendanceRepository = attendanceRepository,
        super(DataInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<AddStudent>(_onAddStudent);
    on<ImportStudents>(_onImportStudents);
    on<ExportAttendance>(_onExportAttendance);
  }

  Future<void> _onLoadStudents(LoadStudents event, Emitter<DataState> emit) async {
      emit(DataLoading());
      try {
          final students = await _studentRepository.getStudents(event.grade);
          emit(DataLoaded(students));
      } catch (e) {
          emit(DataError(e.toString()));
      }
  }

  Future<void> _onAddStudent(AddStudent event, Emitter<DataState> emit) async {
       try {
          await _studentRepository.addStudent(event.student);
          add(const LoadStudents(null));
      } catch (e) {
          emit(DataError(e.toString()));
      }
  }

  Future<void> _onImportStudents(ImportStudents event, Emitter<DataState> emit) async {
    emit(DataLoading());
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        final bytes = File(result.files.single.path!).readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        List<Student> newStudents = [];

        for (var table in excel.tables.keys) {
          // Assume first sheet
           if (excel.tables[table] != null) {
               for (var row in excel.tables[table]!.rows) {
                   // Skip header if needed, or simple check
                   // Expected: Name, Grade
                   if (row.length >= 2) {
                       final name = row[0]?.value.toString();
                       final grade = row[1]?.value.toString();
                       if (name != null && grade != null && name != 'Name') {
                           newStudents.add(Student(
                               id: DateTime.now().microsecondsSinceEpoch.toString() + name, // temporary ID gen
                               name: name,
                               grade: grade,
                           ));
                       }
                   }
               }
           }
        }

        await _studentRepository.importStudents(newStudents);
        emit(DataSuccess('Imported ${newStudents.length} students'));
        add(const LoadStudents(null));
      } else {
        emit(DataInitial());
      }
    } catch (e) {
      emit(DataError('Import failed: $e'));
    }
  }

  Future<void> _onExportAttendance(ExportAttendance event, Emitter<DataState> emit) async {
      emit(DataLoading());
      try {
          // This requires fetching all attendance for date, possibly for all grades?
          // Admin only.
          // We need a repository method to get ALL attendance for date.
          // Current method takes grade. We can iterate grades or add method.
          // Let's assume we iterate known grades or just empty grade means all.
          // Using "All" for grade.
          // But repository implementation needs to handle it.
          // Hack: Fetch all students, then filter.

          final students = await _studentRepository.getStudents(null);
          // Group by grade?
          // We need attendance records.
          // Let's rely on repo getting everything if grade is null (we need to update repo for that, but currently it filters if grade is not null).
          // Checking repo impl: `if (grade != null) ...` -> `getAttendance` takes grade.
          // `getAttendance` impl: `getAttendance(String grade, ...)` -> filtering local hive.
          // We need a way to get ALL attendance.
          // I'll update repo interface later or just loop known grades for now (simplest: Grade 1..12).
          // Or just fetch all from Hive directly via a new method.
          // I will loop through grades '1' to '12' as placeholder, or just fetch all records from hive logic inside bloc for now (not clean but works for Phase 1).

          // Better: Update `AttendanceRepository` to accept null grade for "all".

          // ... Proceeding with assumed "all" fetch capability or list iteration ...
          // For now, I will just export for "Grade 1" as proof of concept or implement a loop.

          var excel = Excel.createExcel();
          Sheet sheet = excel['Attendance'];

          List<String> headers = ['Student Name', 'Grade', 'Date', 'Status', 'Recorded By'];
          sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

          // Getting data (Simplification: fetch all students and check their attendance)
          // This is potentially slow but okay for Phase 1.
          // Actually, we should get all attendance records for that date.
          // Repo: `getAttendance(grade, date)`.

          // Let's assume we have a list of grades.
          List<String> grades = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];

          for (var g in grades) {
              final records = await _attendanceRepository.getAttendance(g, event.date);
              final studentsInGrade = students.where((s) => s.grade == g).toList();

              for (var record in records) {
                  final student = studentsInGrade.firstWhere((s) => s.id == record.studentId, orElse: () => Student(id: '', name: 'Unknown', grade: g));
                  sheet.appendRow([
                      TextCellValue(student.name),
                      TextCellValue(g),
                      TextCellValue(record.date.toString().split(' ')[0]),
                      TextCellValue(record.status.toString().split('.').last),
                      TextCellValue(record.markedByUserId),
                  ]);
              }
          }

          var fileBytes = excel.save();
          var directory = await getApplicationDocumentsDirectory();

          File(join(directory.path, 'attendance_export.xlsx'))
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes!);

          await Share.shareXFiles([XFile(join(directory.path, 'attendance_export.xlsx'))], text: 'Attendance Report');

          emit(const DataSuccess('Export ready'));
      } catch (e) {
          emit(DataError('Export failed: $e'));
      }
  }

    // Helper for path join since I didn't import path package
    String join(String part1, String part2) {
        return part1 + (Platform.isWindows ? '\\' : '/') + part2;
    }
}
