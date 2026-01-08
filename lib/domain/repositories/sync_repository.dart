abstract class SyncRepository {
  Future<void> syncData();
  Stream<bool> get isSyncing;
}
