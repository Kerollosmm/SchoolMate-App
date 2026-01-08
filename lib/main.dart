import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'service_locator.dart' as di;
import 'config/theme/app_theme.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/main_dashboard.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/servant_bloc.dart';
import 'presentation/bloc/attendance_bloc.dart';
import 'presentation/bloc/sync_cubit.dart';
import 'presentation/bloc/data_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase & Hive
  await Firebase.initializeApp();
  await Hive.initFlutter();

  // Initialize DI and Hive Adapters
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => di.sl<ServantBloc>()),
        BlocProvider(create: (_) => di.sl<AttendanceBloc>()),
        BlocProvider(create: (_) => di.sl<SyncCubit>()),
        BlocProvider(create: (_) => di.sl<DataBloc>()),
      ],
      child: MaterialApp(
        title: 'CSMS Phase 1',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const MainDashboard();
        }
        return const LoginPage();
      },
    );
  }
}
