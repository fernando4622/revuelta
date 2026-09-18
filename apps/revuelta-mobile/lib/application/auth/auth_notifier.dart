import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/api_client.dart';
import '../../domain/auth/user_session.dart';
import '../../domain/failure/failure.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, UserSession?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<UserSession?> {
  late final ApiClient _apiClient;

  @override
  Future<UserSession?> build() async {
    _apiClient = ref.watch(apiClientProvider);
    final token = await _apiClient.storage.read(key: 'jwt_token');
    final userId = await _apiClient.storage.read(key: 'user_id');
    final username = await _apiClient.storage.read(key: 'username');
    final role = await _apiClient.storage.read(key: 'role');

    if (token != null && userId != null && username != null && role != null) {
      return UserSession(userId: userId, username: username, role: role, token: token);
    }
    return null;
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final data = await _apiClient.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      final session = UserSession(
        userId: data['userId'],
        username: data['username'],
        role: data['role'],
        token: data['token'],
      );

      await _apiClient.storage.write(key: 'jwt_token', value: session.token);
      await _apiClient.storage.write(key: 'user_id', value: session.userId);
      await _apiClient.storage.write(key: 'username', value: session.username);
      await _apiClient.storage.write(key: 'role', value: session.role);

      state = AsyncValue.data(session);
    } catch (e, stack) {
      if (e is Failure) {
        state = AsyncValue.error(e, stack);
      } else {
        state = AsyncValue.error(AuthFailure(e.toString()), stack);
      }
    }
  }

  Future<void> logout() async {
    await _apiClient.storage.deleteAll();
    state = const AsyncValue.data(null);
  }
}
