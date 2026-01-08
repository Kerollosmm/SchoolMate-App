import '../entities/user_profile.dart';

abstract class ServantRepository {
  Future<List<UserProfile>> getServants();
  Future<void> addServant(UserProfile servant, String password);
  Future<void> updateServant(UserProfile servant);
  Future<void> deleteServant(String id);
}
