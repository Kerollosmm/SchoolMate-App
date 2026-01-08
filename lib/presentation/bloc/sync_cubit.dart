import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/sync_repository.dart';

class SyncCubit extends Cubit<bool> {
  final SyncRepository _repository;

  SyncCubit({required SyncRepository repository})
      : _repository = repository,
        super(false) {
    _repository.isSyncing.listen((isSyncing) {
      emit(isSyncing);
    });
  }

  Future<void> syncNow() async {
    await _repository.syncData();
  }
}
