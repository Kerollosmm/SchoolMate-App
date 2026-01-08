import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'data/datasources/local/hive_service.dart';
import 'data/datasources/remote/firestore_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/servant_repository_impl.dart';
import 'data/repositories/student_repository_impl.dart';
import 'data/repositories/attendance_repository_impl.dart';
import 'data/repositories/sync_repository_impl.dart';

import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/servant_repository.dart';
import 'domain/repositories/student_repository.dart';
import 'domain/repositories/attendance_repository.dart';
import 'domain/repositories/sync_repository.dart';

import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/servant_bloc.dart';
import 'presentation/bloc/attendance_bloc.dart';
import 'presentation/bloc/sync_cubit.dart';
import 'presentation/bloc/data_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  await HiveService.init();
  final hiveService = HiveService(); // Singleton-like via GetIt usually, but class has static methods + instance.
  // Actually HiveService methods are instance based in my implementation except init.
  sl.registerLazySingleton(() => hiveService);

  sl.registerLazySingleton(() => FirestoreService());
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => Connectivity());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    firebaseAuth: sl(),
    firestoreService: sl(),
    hiveService: sl(),
  ));
  sl.registerLazySingleton<ServantRepository>(() => ServantRepositoryImpl(
    firebaseAuth: sl(),
    firestoreService: sl(),
    hiveService: sl(),
  ));
  sl.registerLazySingleton<StudentRepository>(() => StudentRepositoryImpl(
    firestoreService: sl(),
    hiveService: sl(),
  ));
  sl.registerLazySingleton<AttendanceRepository>(() => AttendanceRepositoryImpl(
    hiveService: sl(),
  ));
  sl.registerLazySingleton<SyncRepository>(() => SyncRepositoryImpl(
    firestoreService: sl(),
    hiveService: sl(),
    connectivity: sl(),
  ));

  // Blocs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => ServantBloc(repository: sl()));
  sl.registerFactory(() => AttendanceBloc(attendanceRepository: sl(), studentRepository: sl()));
  sl.registerFactory(() => SyncCubit(repository: sl()));
  sl.registerFactory(() => DataBloc(studentRepository: sl(), attendanceRepository: sl()));
}
