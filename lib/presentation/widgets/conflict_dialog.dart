import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/conflict_record.dart';
import '../../domain/entities/attendance_record.dart';
import '../../core/constants/enums.dart';
import '../bloc/attendance_bloc.dart';

class ConflictDialog extends StatelessWidget {
  final List<ConflictRecord> conflicts;

  const ConflictDialog({super.key, required this.conflicts});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Resolve Conflicts'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: conflicts.length,
          itemBuilder: (context, index) {
            final conflict = conflicts[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student ID: ${conflict.studentId}'),
                    Text('Date: ${conflict.date.toIso8601String().split('T')[0]}'),
                    const SizedBox(height: 8),
                    const Text('Select final status:'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                         ElevatedButton(
                           style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                           onPressed: () => _resolve(context, conflict, AttendanceStatus.present),
                           child: const Text('Present'),
                         ),
                         ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                           onPressed: () => _resolve(context, conflict, AttendanceStatus.absent),
                           child: const Text('Absent'),
                         ),
                         ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                           onPressed: () => _resolve(context, conflict, AttendanceStatus.excused),
                           child: const Text('Excused'),
                         ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }

  void _resolve(BuildContext context, ConflictRecord conflict, AttendanceStatus status) {
      final resolvedRecord = AttendanceRecord(
          id: conflict.conflictingRecords.isNotEmpty ? conflict.conflictingRecords.first.id : DateTime.now().toString(), // Re-use ID if possible
          studentId: conflict.studentId,
          date: conflict.date,
          status: status,
          markedByUserId: 'admin', // Resolved by admin
          markedAt: DateTime.now(),
          syncStatus: SyncStatus.pending, // Will overwrite remote
      );

      context.read<AttendanceBloc>().add(ResolveConflict(conflict.id, resolvedRecord));
      Navigator.pop(context); // Close after one resolution or keep open? keep open if multiple.
      // But Navigator.pop closes the dialog.
      // Ideally we refresh the list.
  }
}
