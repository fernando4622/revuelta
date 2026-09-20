import 'package:flutter_test/flutter_test.dart';
import 'package:revuelta_mobile/domain/auth/user_role.dart';

void main() {
  group('UserRole.fromWire', () {
    test('maps every supported backend role', () {
      expect(UserRole.fromWire('PARTICIPANT'), UserRole.participant);
      expect(UserRole.fromWire('OPERATOR'), UserRole.operator);
      expect(UserRole.fromWire('ADMIN'), UserRole.admin);
    });

    test('fails closed for missing or unknown roles', () {
      expect(UserRole.fromWire(null), UserRole.unsupported);
      expect(UserRole.fromWire(''), UserRole.unsupported);
      expect(UserRole.fromWire('SUPERUSER'), UserRole.unsupported);
      expect(UserRole.fromWire('participant'), UserRole.unsupported);
    });
  });
}
