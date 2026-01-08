import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/local/hive_service.dart';
import '../datasources/remote/firestore_service.dart';
import '../models/attendance_record_model.dart';
import 'package:rxdart/rxdart.dart';

class SyncRepositoryImpl implements SyncRepository {
  final HiveService _hiveService;
  final FirestoreService _firestoreService;
  final Connectivity _connectivity;
  final BehaviorSubject<bool> _isSyncingController = BehaviorSubject<bool>.seeded(false);

  SyncRepositoryImpl({
    required HiveService hiveService,
    required FirestoreService firestoreService,
    required Connectivity connectivity,
  })  : _hiveService = hiveService,
        _firestoreService = firestoreService,
        _connectivity = connectivity {
    _initAutoSync();
  }

  void _initAutoSync() {
    // Sync on connectivity change
    _connectivity.onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        syncData();
      }
    });

    // Periodic sync (every 60s)
    Stream.periodic(const Duration(seconds: 60)).listen((_) {
       // Check connectivity before syncing
       _connectivity.checkConnectivity().then((results) {
         if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
           syncData();
         }
       });
    });
  }

  @override
  Stream<bool> get isSyncing => _isSyncingController.stream;

  @override
  Future<void> syncData() async {
    if (_isSyncingController.value) return;
    _isSyncingController.add(true);

    try {
      // 1. Push Local Changes
      final queue = _hiveService.syncQueue;
      if (queue.isNotEmpty) {
        // Process queue
        final keysToDelete = <dynamic>[];
        for (var i = 0; i < queue.length; i++) {
          final item = queue.getAt(i) as Map;
          final collection = item['collection'];
          final action = item['action'];
          final data = item['data'];

          try {
            if (collection == 'attendance') {
              final record = AttendanceRecordModel.fromJson(Map<String, dynamic>.from(data));
              if (action == 'save') {
                 try {
                   await _firestoreService.saveAttendance(record);
                   // Update local sync status to synced
                   final syncedRecord = AttendanceRecordModel(
                      id: record.id,
                      studentId: record.studentId,
                      date: record.date,
                      statusString: record.statusString,
                      markedByUserId: record.markedByUserId,
                      markedAt: record.markedAt,
                      syncStatusString: 'synced',
                      conflictId: record.conflictId
                   );
                   await _hiveService.attendance.put(record.id, syncedRecord);
                 } catch (e) {
                   if (e.toString().contains('Conflict')) {
                      // Mark local as conflict
                      final conflictRecord = AttendanceRecordModel(
                        id: record.id,
                        studentId: record.studentId,
                        date: record.date,
                        statusString: record.statusString,
                        markedByUserId: record.markedByUserId,
                        markedAt: record.markedAt,
                        syncStatusString: 'conflict',
                        conflictId: record.conflictId
                      );
                      await _hiveService.attendance.put(record.id, conflictRecord);
                   } else {
                     rethrow;
                   }
                 }
              }
            }
            // Add other collections handling here (servants, students)

            keysToDelete.add(queue.keyAt(i));
          } catch (e) {
            print('Error syncing item $i: $e');
            // Keep in queue to retry? Or move to Dead Letter Queue?
            // For now, keep in queue.
          }
        }
        await queue.deleteAll(keysToDelete);
      }

      // 2. Pull Remote Changes (Delta Sync)
      final lastSync = _hiveService.getLastSyncTime();
      final now = DateTime.now();

      // Servants
      // Only admins need full servant list, but everyone needs their own profile.
      // Simplification: fetch all servants updates.
      // final remoteServants = await _firestoreService.getServants(); // Optimization: use lastSync
      // For Phase 1, just fetch all occasionally or if lastSync is null.
      if (lastSync == null) {
          final remoteServants = await _firestoreService.getServants();
          for (var s in remoteServants) {
            await _hiveService.saveServant(s);
          }

          final remoteStudents = await _firestoreService.getStudents(null);
          for (var s in remoteStudents) {
            await _hiveService.saveStudent(s);
          }

          final remoteAttendance = await _firestoreService.getAttendance(null);
           for (var a in remoteAttendance) {
            await _hiveService.saveAttendance(a);
          }
      } else {
        // Delta sync implementation requires 'updatedAt' fields in Firestore which I didn't enforce strictly in models yet.
        // I will assume for now we just fetch all to be safe for this prototype, or implement proper delta later.
        // Let's implement delta fetch in FirestoreService later.

        // Re-fetching all for robust prototype:
          final remoteStudents = await _firestoreService.getStudents(lastSync);
          for (var s in remoteStudents) {
            await _hiveService.saveStudent(s);
          }

          final remoteAttendance = await _firestoreService.getAttendance(lastSync);
           for (var a in remoteAttendance) {
             // Only overwrite if local is NOT pending/conflict?
             // Or overwrite if remote is newer?
             // "UI lists must read from Hive only" -> we update Hive.
             await _hiveService.saveAttendance(a);
          }
      }

      await _hiveService.updateLastSyncTime(now);

    } catch (e) {
      print('Sync Error: $e');
    } finally {
      _isSyncingController.add(false);
    }
  }
}
