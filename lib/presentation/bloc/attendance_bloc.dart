import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/conflict_record.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/student_repository.dart';

// Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

class LoadAttendance extends AttendanceEvent {
  final String grade;
  final DateTime date;
  const LoadAttendance(this.grade, this.date);
}

class MarkAttendance extends AttendanceEvent {
  final AttendanceRecord record;
  const MarkAttendance(this.record);
}

class ResolveConflict extends AttendanceEvent {
  final String conflictId;
  final AttendanceRecord resolvedRecord;
  const ResolveConflict(this.conflictId, this.resolvedRecord);
}

// States
abstract class AttendanceState extends Equatable {
  const AttendanceState();
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}
class AttendanceLoading extends AttendanceState {}
class AttendanceLoaded extends AttendanceState {
  final List<Student> students;
  final Map<String, AttendanceRecord> attendance; // Map studentId -> Record
  final List<ConflictRecord> conflicts;
  final String grade;
  final DateTime date;

  const AttendanceLoaded({
    required this.students,
    required this.attendance,
    required this.conflicts,
    required this.grade,
    required this.date,
  });

  @override
  List<Object?> get props => [students, attendance, conflicts, grade, date];
}
class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _attendanceRepository;
  final StudentRepository _studentRepository;

  AttendanceBloc({
    required AttendanceRepository attendanceRepository,
    required StudentRepository studentRepository,
  })  : _attendanceRepository = attendanceRepository,
        _studentRepository = studentRepository,
        super(AttendanceInitial()) {
    on<LoadAttendance>(_onLoadAttendance);
    on<MarkAttendance>(_onMarkAttendance);
    on<ResolveConflict>(_onResolveConflict);
  }

  Future<void> _onLoadAttendance(LoadAttendance event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final students = await _studentRepository.getStudents(event.grade);
      final records = await _attendanceRepository.getAttendance(event.grade, event.date);
      final conflicts = await _attendanceRepository.getConflicts();

      final attendanceMap = {for (var r in records) r.studentId: r};

      emit(AttendanceLoaded(
        students: students,
        attendance: attendanceMap,
        conflicts: conflicts,
        grade: event.grade,
        date: event.date,
      ));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onMarkAttendance(MarkAttendance event, Emitter<AttendanceState> emit) async {
    final currentState = state;
    if (currentState is AttendanceLoaded) {
      try {
        await _attendanceRepository.markAttendance(event.record);
        // Optimistic update
        final newMap = Map<String, AttendanceRecord>.from(currentState.attendance);
        newMap[event.record.studentId] = event.record;

        emit(AttendanceLoaded(
          students: currentState.students,
          attendance: newMap,
          conflicts: currentState.conflicts,
          grade: currentState.grade,
          date: currentState.date,
        ));
      } catch (e) {
         emit(AttendanceError(e.toString()));
      }
    }
  }

  Future<void> _onResolveConflict(ResolveConflict event, Emitter<AttendanceState> emit) async {
    // Similar to mark, but calls resolve
     try {
        await _attendanceRepository.resolveConflict(event.conflictId, event.resolvedRecord);
        add(LoadAttendance(event.resolvedRecord.date.toIso8601String(), event.resolvedRecord.date)); // Reload to refresh state properly
     } catch (e) {
        emit(AttendanceError(e.toString()));
     }
  }
}
