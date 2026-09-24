import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/return_flow/api_return_repository.dart';
import '../auth/auth_notifier.dart';
import 'return_repository.dart';

final returnRepositoryProvider = Provider<ReturnRepository>(
  (ref) => ApiReturnRepository(ref.watch(apiClientProvider)),
);
