import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/delivery/api_delivery_repository.dart';
import '../auth/auth_notifier.dart';
import 'delivery_repository.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>(
  (ref) => ApiDeliveryRepository(ref.watch(apiClientProvider)),
);
