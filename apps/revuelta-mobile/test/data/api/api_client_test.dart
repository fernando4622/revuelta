import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/application/auth/session_storage.dart';
import 'package:revuelta_mobile/data/api/api_client.dart';
import 'package:revuelta_mobile/domain/failure/failure.dart';

void main() {
  test('uses the explicitly configured API base URL', () {
    final client = ApiClient(baseUrl: 'https://api.example.test/api/v1');

    expect(client.dio.options.baseUrl, 'https://api.example.test/api/v1');
  });

  test('expired session clears credentials and emits session expiration',
      () async {
    final storage = _MemorySessionStorage({'jwt_token': 'expired-token'});
    var expirationEvents = 0;
    final client = _errorClient(
      status: 401,
      code: 'UNAUTHENTICATED',
      storage: storage,
      onSessionExpired: () => expirationEvents++,
    );

    await expectLater(
      client.get('/containers'),
      throwsA(isA<SessionExpiredFailure>()),
    );

    expect(storage.values, isEmpty);
    expect(expirationEvents, 1);
  });

  test('invalid login does not expire an existing session', () async {
    final storage = _MemorySessionStorage({'jwt_token': 'current-token'});
    var expirationEvents = 0;
    final client = _errorClient(
      status: 401,
      code: 'INVALID_CREDENTIALS',
      storage: storage,
      onSessionExpired: () => expirationEvents++,
    );

    await expectLater(
      client.post('/auth/login'),
      throwsA(
        isA<AuthFailure>().having(
          (failure) => failure.code,
          'code',
          'INVALID_CREDENTIALS',
        ),
      ),
    );

    expect(storage.values['jwt_token'], 'current-token');
    expect(expirationEvents, 0);
  });

  test('forbidden response preserves session and stable error code', () async {
    final storage = _MemorySessionStorage({'jwt_token': 'current-token'});
    var expirationEvents = 0;
    final client = _errorClient(
      status: 403,
      code: 'FORBIDDEN_OPERATION',
      storage: storage,
      onSessionExpired: () => expirationEvents++,
    );

    await expectLater(
      client.get('/containers'),
      throwsA(
        isA<ForbiddenFailure>().having(
          (failure) => failure.code,
          'code',
          'FORBIDDEN_OPERATION',
        ),
      ),
    );

    expect(storage.values['jwt_token'], 'current-token');
    expect(expirationEvents, 0);
  });
}

ApiClient _errorClient({
  required int status,
  required String code,
  required _MemorySessionStorage storage,
  required SessionExpiredCallback onSessionExpired,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1'));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) => handler.reject(
      DioException(
        requestOptions: options,
        response: Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: status,
          data: {'detail': 'Server detail', 'code': code},
        ),
        type: DioExceptionType.badResponse,
      ),
    ),
  ));
  return ApiClient(
    dioClient: dio,
    sessionStore: storage,
    onSessionExpired: onSessionExpired,
  );
}

class _MemorySessionStorage implements SessionStorage {
  _MemorySessionStorage([Map<String, String>? initialValues])
      : values = {...?initialValues};

  final Map<String, String> values;

  @override
  Future<void> deleteAll() async => values.clear();

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
