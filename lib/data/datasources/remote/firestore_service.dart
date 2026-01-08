import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile_model.dart';
import '../../models/student_model.dart';
import '../../models/attendance_record_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserProfileModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('servants').doc(uid).get();
    if (doc.exists) {
      return UserProfileModel.fromJson({...doc.data()!, 'uid': doc.id});
    }
    return null;
  }

  Future<List<UserProfileModel>> getServants() async {
    final snapshot = await _firestore.collection('servants').get();
    return snapshot.docs.map((doc) => UserProfileModel.fromJson({...doc.data(), 'uid': doc.id})).toList();
  }

  Future<void> saveServant(UserProfileModel servant) async {
    await _firestore.collection('servants').doc(servant.id).set(servant.toJson());
  }

  Future<void> deleteServant(String id) async {
    await _firestore.collection('servants').doc(id).delete();
  }

  Future<List<StudentModel>> getStudents(DateTime? since) async {
    Query query = _firestore.collection('students');
    // if (since != null) {
    //   query = query.where('updatedAt', isGreaterThan: since);
    // }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => StudentModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id})).toList();
  }

  Future<void> saveStudent(StudentModel student) async {
    await _firestore.collection('students').doc(student.id).set(student.toJson());
  }

  Future<void> deleteStudent(String id) async {
    await _firestore.collection('students').doc(id).delete();
  }

  Future<List<AttendanceRecordModel>> getAttendance(DateTime? since) async {
    Query query = _firestore.collection('attendance');
    // if (since != null) {
    //   query = query.where('markedAt', isGreaterThan: since);
    // }
    // Fetch limited range? For now fetch all since last sync.
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => AttendanceRecordModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id})).toList();
  }

  Future<void> saveAttendance(AttendanceRecordModel record) async {
    // Check for conflict here if needed, but RBAC says we push to background queue.
    // However, if we are online, the sync engine will call this.
    // For conflict protocol: If document exists and has different status -> Conflict.
    // Phase 1 Requirement: "If two different users mark different status ... do not overwrite"

    final docRef = _firestore.collection('attendance').doc(record.id);
    final doc = await docRef.get();

    if (doc.exists) {
      final remoteData = doc.data()!;
      // If forceSync is true (indicated by syncStatus == 'pending' coming from resolution), we overwrite.
      // But record.syncStatusString might be 'pending'.

      // If different status AND different user, AND it's NOT a resolution (how to know? Maybe by markedByUserId == 'admin'?)
      // Requirement: "Admin can resolve... update both local and remote"
      // If admin resolves, markedBy might be 'admin' or the original user.
      // Let's use a convention: If syncStatusString is 'pending', we try to save.
      // But if it is 'pending' AND conflicts with remote, we throw exception?
      // No, we need a way to say "Force Overwrite".
      // Let's check if the record passed has a special flag or if we trust 'pending' from SyncRepository implies "Local is truth".
      // But we ONLY want to overwrite if it's a RESOLUTION or if there is NO conflict.

      // If conflict detected (Different status, different user)
      if (remoteData['status'] != record.statusString && remoteData['markedByUserId'] != record.markedByUserId) {
         // EXCEPTION: If the user is Admin (or resolved), we allow overwrite?
         // record.markedByUserId == 'admin' is weak check.
         // Let's look at `syncStatusString`. If it was `conflict` locally, we resolved it to `pending`.
         // So `pending` means "I am the new truth".
         // The issue is: The ORIGINAL conflicting record was also `pending` before it became `conflict`.

         // Fix: If remote has `conflictId` populated, maybe we respect it?
         // Or just check timestamps?

         // For Phase 1 strict requirement: "If two different users mark different status ... do not overwrite".
         // Admin Resolution IS an overwrite.

         // We can check if `record.conflictId` is null (resolved) vs populated?
         // In my `resolveConflict` logic, I set `conflictId: null`.

         if (record.conflictId == null && record.markedByUserId == 'admin') {
             // Admin resolution, allow overwrite.
         } else {
             throw Exception('Conflict detected');
         }
      }
    }

    await docRef.set(record.toJson());
  }
}
