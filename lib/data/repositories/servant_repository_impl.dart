import 'package:uuid/uuid.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/servant_repository.dart';
import '../datasources/local/hive_service.dart';
import '../datasources/remote/firestore_service.dart';
import '../models/user_profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServantRepositoryImpl implements ServantRepository {
  final HiveService _hiveService;
  final FirestoreService _firestoreService;
  final FirebaseAuth _firebaseAuth;

  ServantRepositoryImpl({
    required HiveService hiveService,
    required FirestoreService firestoreService,
    required FirebaseAuth firebaseAuth,
  })  : _hiveService = hiveService,
        _firestoreService = firestoreService,
        _firebaseAuth = firebaseAuth;

  @override
  Future<List<UserProfile>> getServants() async {
    return _hiveService.getAllServants();
  }

  @override
  Future<void> addServant(UserProfile servant, String password) async {
    // 1. Create Auth User (This requires Admin SDK ideally, or secondary app instance,
    // but in client SDK we can't easily create another user without logging out.
    // WORKAROUND: Create user in Firestore only, and let them sign up?
    // Or just fail if we can't create Auth.
    // Common pattern: Admin creates Firestore record. User signs up/logs in, and we match email.
    // Or we use a cloud function.
    // For this Phase 1 without backend logic:
    // We will just create the Firestore document. The actual Auth creation is tricky from client side for *another* user.
    // Let's assume the "Add Servant" just adds the record to DB.
    // BUT requirements say "Secure Authentication".
    // I will Implement: Admin creates record.
    // User performs "First Login" or "Sign Up" where they set their password, and we check if their email is in 'servants' collection.

    // HOWEVER, the prompt says "Login page: email + password".
    // I will skip the "Create Auth User" part in code (impossible safely from client) and assume accounts are pre-provisioned or created via separate admin tool/console, OR I will simply create the Firestore document and assume that triggers a Cloud Function (simulated).
    // Actually, I can use a secondary Firebase App instance to create users, but that exposes admin creds.
    // Let's stick to: Save to Firestore/Hive.

    final model = UserProfileModel.fromEntity(servant);
    await _hiveService.saveServant(model);
    await _firestoreService.saveServant(model);

    // Note: This does NOT create the Firebase Auth user.
  }

  @override
  Future<void> updateServant(UserProfile servant) async {
    final model = UserProfileModel.fromEntity(servant);
    await _hiveService.saveServant(model);
    await _firestoreService.saveServant(model);
  }

  @override
  Future<void> deleteServant(String id) async {
    await _hiveService.deleteServant(id);
    await _firestoreService.deleteServant(id);
  }
}
