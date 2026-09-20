import 'user_role.dart';

class UserSession {
  final String userId;
  final String username;
  final UserRole role;
  final String token;

  const UserSession({
    required this.userId,
    required this.username,
    required this.role,
    required this.token,
  });
}
