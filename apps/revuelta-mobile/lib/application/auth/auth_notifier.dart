import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/api_client.dart';
import '../../domain/auth/user_session.dart';
import '../../domain/auth/user_role.dart';
import '../../domain/failure/failure.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserSession?>(() {
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
    final storedRole = await _apiClient.storage.read(key: 'role');

    final values = [token, userId, username, storedRole];
    final hasAnyStoredValue = values.any((value) => value != null);
    final hasCompleteSession = values.every((value) => value != null);

    if (!hasCompleteSession) {
      if (hasAnyStoredValue) {
        await _apiClient.storage.deleteAll();
      }
      return null;
    }

    final role = UserRole.fromWire(storedRole);
    if (!role.isSupported) {
      await _apiClient.storage.deleteAll();
    }

    return UserSession(
      userId: userId!,
      username: username!,
      role: role,
      token: token!,
    );
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final data = await _apiClient.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      final role = UserRole.fromWire(data['role'] as String?);
      final session = UserSession(
        userId: data['userId'] as String,
        username: data['username'] as String,
        role: role,
        token: data['token'] as String,
      );

      if (!role.isSupported) {
        await _apiClient.storage.deleteAll();
        state = AsyncValue.data(session);
        return;
      }

      await _apiClient.storage.write(key: 'jwt_token', value: session.token);
      await _apiClient.storage.write(key: 'user_id', value: session.userId);
      await _apiClient.storage.write(key: 'username', value: session.username);
      await _apiClient.storage.write(key: 'role', value: session.role.wireName);

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
