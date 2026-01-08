import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/firestore_service.dart';
import '../datasources/local/hive_service.dart';
import '../models/user_profile_model.dart';
import '../../core/constants/enums.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirestoreService _firestoreService;
  final HiveService _hiveService;

  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirestoreService firestoreService,
    required HiveService hiveService,
  })  : _firebaseAuth = firebaseAuth,
        _firestoreService = firestoreService,
        _hiveService = hiveService;

  @override
  Future<UserProfile> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    // Try fetching from remote first (to get latest role/status)
    try {
      final profile = await _firestoreService.getUserProfile(uid);
      if (profile != null) {
        // Cache it
        await _hiveService.saveServant(profile);
        return profile;
      }
    } catch (e) {
      // Offline or error, try local
    }

    // Fallback to local
    final localProfile = _hiveService.servants.get(uid);
    if (localProfile != null) {
      return localProfile;
    }

    throw Exception('User profile not found.');
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    // Try local first for speed
    final localProfile = _hiveService.servants.get(user.uid);
    if (localProfile != null) return localProfile;

    // Fetch remote
    final profile = await _firestoreService.getUserProfile(user.uid);
    if (profile != null) {
      await _hiveService.saveServant(profile);
    }
    return profile;
  }
}
