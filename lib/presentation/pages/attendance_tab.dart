import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // Moved to top
import '../../core/constants/enums.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/attendance_bloc.dart';
import '../widgets/conflict_dialog.dart';

class AttendanceTab extends StatefulWidget {
  final UserProfile user;
  const AttendanceTab({super.key, required this.user});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedGrade;

  @override
  void initState() {
    super.initState();
    // Default grade: first assigned grade or '1'
    if (widget.user.assignedGrades.isNotEmpty) {
      _selectedGrade = widget.user.assignedGrades.first;
    } else {
      _selectedGrade = '1'; // Default
    }
    _loadData();
  }

  void _loadData() {
    if (_selectedGrade != null) {
      context.read<AttendanceBloc>().add(LoadAttendance(_selectedGrade!, _selectedDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Date Picker
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                    _loadData();
                  }
                },
              ),
              const Spacer(),
              // Grade Dropdown
              DropdownButton<String>(
                value: _selectedGrade,
                items: (widget.user.role == UserRole.admin
                        ? ['1','2','3','4','5','6','7','8','9','10','11','12'] // Admin sees all
                        : widget.user.assignedGrades) // Servant sees assigned
                    .map((g) => DropdownMenuItem(value: g, child: Text('Grade $g')))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedGrade = val;
                    });
                    _loadData();
                  }
                },
              ),
            ],
          ),
        ),

        // Conflict Warning
        BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceLoaded && state.conflicts.isNotEmpty && widget.user.role == UserRole.admin) {
              return Container(
                color: Colors.orange.withOpacity(0.2),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                     const Icon(Icons.warning, color: Colors.orange),
                     const SizedBox(width: 8),
                     Text('${state.conflicts.length} Conflicts Detected'),
                     const Spacer(),
                     TextButton(
                       onPressed: () {
                         showDialog(context: context, builder: (_) => ConflictDialog(conflicts: state.conflicts));
                       },
                       child: const Text('Resolve'),
                     )
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // List
        Expanded(
          child: BlocBuilder<AttendanceBloc, AttendanceState>(
            builder: (context, state) {
              if (state is AttendanceLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AttendanceLoaded) {
                if (state.students.isEmpty) {
                  return const Center(child: Text('No students found for this grade.'));
                }
                return ListView.builder(
                  itemCount: state.students.length,
                  itemBuilder: (context, index) {
                    final student = state.students[index];
                    final record = state.attendance[student.id];
                    final status = record?.status;

                    return ListTile(
                      title: Text(student.name),
                      subtitle: Text(record?.syncStatus == SyncStatus.conflict ? 'Conflict detected!' : ''),
                      tileColor: record?.syncStatus == SyncStatus.conflict ? Colors.red.withOpacity(0.1) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _statusButton(student.id, AttendanceStatus.present, status),
                          _statusButton(student.id, AttendanceStatus.absent, status),
                          _statusButton(student.id, AttendanceStatus.excused, status),
                          if (record != null)
                             Icon(
                               record.syncStatus == SyncStatus.synced ? Icons.cloud_done :
                               record.syncStatus == SyncStatus.conflict ? Icons.error : Icons.cloud_upload,
                               size: 16,
                               color: Colors.grey,
                             )
                        ],
                      ),
                    );
                  },
                );
              } else if (state is AttendanceError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _statusButton(String studentId, AttendanceStatus status, AttendanceStatus? currentStatus) {
    final isSelected = status == currentStatus;
    Color color;
    IconData icon;

    switch (status) {
      case AttendanceStatus.present:
        color = Colors.green;
        icon = Icons.check;
        break;
      case AttendanceStatus.absent:
        color = Colors.red;
        icon = Icons.close;
        break;
      case AttendanceStatus.excused:
        color = Colors.orange;
        icon = Icons.info_outline;
        break;
    }

    return IconButton(
      icon: Icon(icon, color: isSelected ? color : Colors.grey.shade300),
      onPressed: () {
        // Find existing ID
        final currentState = context.read<AttendanceBloc>().state;
        String idToUse = const Uuid().v4(); // Fallback

        if (currentState is AttendanceLoaded) {
           if (currentState.attendance.containsKey(studentId)) {
             idToUse = currentState.attendance[studentId]!.id;
           }
        }

        final finalRecord = AttendanceRecord(
           id: idToUse,
           studentId: studentId,
           date: _selectedDate,
           status: status,
           markedByUserId: widget.user.id,
           markedAt: DateTime.now(),
        );

        context.read<AttendanceBloc>().add(MarkAttendance(finalRecord));
      },
    );
  }
}
