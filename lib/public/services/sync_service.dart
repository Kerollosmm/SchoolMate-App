import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:school_management_system/public/models/attendance_model.dart';
import 'package:school_management_system/public/models/conflict_model.dart';
import 'package:school_management_system/public/services/local_db_service.dart';
import 'package:uuid/uuid.dart';

class SyncService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncAll() async {
    // 1. Push pending changes
    await pushChanges();
    // 2. Pull new changes
    await pullChanges();
  }

  Future<void> pushChanges() async {
    var box = LocalDBService.attendanceBox;
    var conflictsBox = LocalDBService.conflictsBox;

    // Find pending records
    List<AttendanceRecord> pending = box.values
      .map((e) => AttendanceRecord.fromJson(Map<String, dynamic>.from(e)))
      .where((r) => r.syncStatus == 'pending')
      .toList();

    for (var localRecord in pending) {
      try {
        // Check remote first for conflict
        // We use a composite doc ID: "YYYY-MM-DD_studentId"
        String docId = localRecord.id;

        DocumentSnapshot remoteDoc = await _firestore.collection('attendance').doc(docId).get();

        if (remoteDoc.exists) {
          var remoteData = remoteDoc.data() as Map<String, dynamic>;
          String remoteStatus = remoteData['status'];

          if (remoteStatus != localRecord.status) {
            // CONFLICT DETECTED
            String conflictId = Uuid().v4();
            ConflictRecord conflict = ConflictRecord(
              id: conflictId,
              studentId: localRecord.studentId,
              studentName: localRecord.studentName,
              date: localRecord.date,
              localVersion: localRecord.toJson(),
              remoteVersion: remoteData,
              detectedAt: DateTime.now().toIso8601String(),
            );

            await conflictsBox.put(conflictId, conflict.toJson());

            // Mark local as conflict
            AttendanceRecord updatedLocal = localRecord.copyWith(syncStatus: 'conflict');
            await box.put(localRecord.id, updatedLocal.toJson());

            continue; // Skip write
          }
        }

        // No conflict, or remote matches local (idempotent), or remote doesn't exist
        // Write to Firestore
        // We set syncStatus to 'synced' in Firestore too?
        // Firestore record serves as "Truth", so syncStatus field in Firestore isn't strictly needed
        // but we can keep it consistent.
        AttendanceRecord toUpload = localRecord.copyWith(syncStatus: 'synced');
        await _firestore.collection('attendance').doc(docId).set(toUpload.toJson());

        // Update local
        await box.put(localRecord.id, toUpload.toJson());

      } catch (e) {
        print("Sync error for ${localRecord.id}: $e");
      }
    }
  }

  Future<void> pullChanges() async {
    // Basic pull: fetch all attendance for recent dates?
    // Or just fetch all and update local if local isn't pending.
    // For Phase 1, let's fetch last 7 days? Or all?
    // Let's fetch all for simplicity or reliance on live listeners in a real app.
    // Here we do a one-time pull.

    try {
        // Optimization: only fetch if we have a "lastSync" timestamp.
        // For now, fetch all from 'attendance' collection.
        QuerySnapshot snap = await _firestore.collection('attendance').get();
        var box = LocalDBService.attendanceBox;

        for (var doc in snap.docs) {
           var data = doc.data() as Map<String, dynamic>;
           AttendanceRecord remoteRecord = AttendanceRecord.fromJson(data);

           // Check local status
           var localData = box.get(remoteRecord.id);
           if (localData != null) {
              AttendanceRecord localRecord = AttendanceRecord.fromJson(Map<String, dynamic>.from(localData));
              if (localRecord.syncStatus == 'pending' || localRecord.syncStatus == 'conflict') {
                 // Don't overwrite pending/conflict changes with pull
                 continue;
              }
           }

           // Update local
           await box.put(remoteRecord.id, remoteRecord.toJson());
        }
    } catch (e) {
      print("Pull error: $e");
    }
  }
}
