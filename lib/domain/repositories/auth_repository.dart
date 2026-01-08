import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile> login(String email, String password);
  Future<void> logout();
  Future<UserProfile?> getCurrentUser();
}
