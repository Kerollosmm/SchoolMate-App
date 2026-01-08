import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/student.dart';
import '../bloc/data_bloc.dart';

class DataTab extends StatelessWidget {
  const DataTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Actions
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Import Students (xlsx)'),
                onPressed: () {
                  context.read<DataBloc>().add(ImportStudents());
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Export Report'),
                onPressed: () {
                  // Export for "today" by default
                  context.read<DataBloc>().add(ExportAttendance(DateTime.now()));
                },
              ),
            ],
          ),
        ),

        // Status/Message
        BlocBuilder<DataBloc, DataState>(
           builder: (context, state) {
               if (state is DataLoading) return const LinearProgressIndicator();
               if (state is DataSuccess) return Padding(padding: const EdgeInsets.all(8), child: Text(state.message, style: const TextStyle(color: Colors.green)));
               if (state is DataError) return Padding(padding: const EdgeInsets.all(8), child: Text(state.message, style: const TextStyle(color: Colors.red)));
               return const SizedBox.shrink();
           },
        ),

        const Divider(),
        const Padding(padding: EdgeInsets.all(8), child: Text('Student Directory', style: TextStyle(fontWeight: FontWeight.bold))),

        // List
        Expanded(
          child: BlocBuilder<DataBloc, DataState>(
            bloc: context.read<DataBloc>()..add(const LoadStudents(null)), // Load on init
            builder: (context, state) {
                if (state is DataLoaded) {
                    return ListView.builder(
                        itemCount: state.students.length,
                        itemBuilder: (context, index) {
                            final s = state.students[index];
                            return ListTile(
                                title: Text(s.name),
                                subtitle: Text('Grade: ${s.grade}'),
                            );
                        },
                    );
                }
                return const Center(child: Text('No students loaded.'));
            },
          ),
        ),
      ],
    );
  }
}
