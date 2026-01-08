import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/enums.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/sync_cubit.dart';
import 'attendance_tab.dart';
import 'servants_tab.dart';
import 'data_tab.dart';
import 'login_page.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          // Should not happen if guarded, but safe fallback
          return const LoginPage();
        }

        final user = authState.user;
        final isAdmin = user.role == UserRole.admin;

        // Define tabs based on role
        final List<Widget> tabs = [];
        final List<BottomNavigationBarItem> navItems = [];

        // Attendance (Everyone)
        tabs.add(AttendanceTab(user: user));
        navItems.add(const BottomNavigationBarItem(
          icon: Icon(Icons.check_circle_outline),
          label: 'Attendance',
        ));

        // Servants (Admin Only)
        if (isAdmin) {
          tabs.add(const ServantsTab());
          navItems.add(const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Servants',
          ));
        }

        // Data (Admin Only)
        if (isAdmin) {
          tabs.add(const DataTab());
          navItems.add(const BottomNavigationBarItem(
            icon: Icon(Icons.dataset),
            label: 'Data',
          ));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('CSMS - ${user.name}'),
            actions: [
              // Sync Status Indicator
              BlocBuilder<SyncCubit, bool>(
                builder: (context, isSyncing) {
                  return IconButton(
                    icon: Icon(
                      isSyncing ? Icons.sync : Icons.cloud_done,
                      color: isSyncing ? Colors.blue : Colors.green,
                    ),
                    onPressed: () {
                      context.read<SyncCubit>().syncNow();
                    },
                    tooltip: isSyncing ? 'Syncing...' : 'Synced',
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
          body: tabs.length > _currentIndex ? tabs[_currentIndex] : tabs[0],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: navItems,
          ),
        );
      },
    );
  }
}
