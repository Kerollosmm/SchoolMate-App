import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../../core/constants/enums.dart';
import '../bloc/servant_bloc.dart';

class ServantsTab extends StatefulWidget {
  const ServantsTab({super.key});

  @override
  State<ServantsTab> createState() => _ServantsTabState();
}

class _ServantsTabState extends State<ServantsTab> {
  @override
  void initState() {
    super.initState();
    context.read<ServantBloc>().add(LoadServants());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ServantBloc, ServantState>(
        builder: (context, state) {
          if (state is ServantLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ServantLoaded) {
            return ListView.builder(
              itemCount: state.servants.length,
              itemBuilder: (context, index) {
                final servant = state.servants[index];
                return ListTile(
                  title: Text(servant.name),
                  subtitle: Text('${servant.email} - ${servant.role == UserRole.admin ? 'Admin' : 'Servant'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                        // Confirm
                        showDialog(context: context, builder: (_) => AlertDialog(
                            title: const Text('Delete?'),
                            content: const Text('Are you sure? This cannot be undone.'),
                            actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                TextButton(onPressed: () {
                                    context.read<ServantBloc>().add(DeleteServant(servant.id));
                                    Navigator.pop(context);
                                }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                        ));
                    },
                  ),
                );
              },
            );
          } else if (state is ServantError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final passCtrl = TextEditingController(); // Only for creation
    final gradeCtrl = TextEditingController(); // Comma separated for now
    UserRole role = UserRole.servant;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Servant'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                  TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password')),
                  TextField(controller: gradeCtrl, decoration: const InputDecoration(labelText: 'Grades (e.g. 1,2)')),
                  DropdownButton<UserRole>(
                    value: role,
                    items: const [
                       DropdownMenuItem(value: UserRole.servant, child: Text('Servant')),
                       DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
                    ],
                    onChanged: (val) {
                        if (val != null) setState(() => role = val);
                    },
                  )
                ],
              ),
            ),
            actions: [
               TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
               TextButton(onPressed: () {
                   final grades = gradeCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                   final newUser = UserProfile(
                       id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID, repo should handle better or use UUID
                       email: emailCtrl.text,
                       name: nameCtrl.text,
                       role: role,
                       isActive: true,
                       assignedGrades: grades,
                   );
                   context.read<ServantBloc>().add(AddServant(newUser, passCtrl.text));
                   Navigator.pop(context);
               }, child: const Text('Add')),
            ],
          );
        }
      ),
    );
  }
}
