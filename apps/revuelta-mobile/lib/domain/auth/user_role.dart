enum UserRole {
  participant('PARTICIPANT', 'Alumno / maestro'),
  operator('OPERATOR', 'Cafetería'),
  admin('ADMIN', 'Operación ReVuelta'),
  unsupported('UNSUPPORTED', 'Acceso no disponible');

  const UserRole(this.wireName, this.displayName);

  final String wireName;
  final String displayName;

  bool get isSupported => this != UserRole.unsupported;

  static UserRole fromWire(String? value) {
    for (final role in UserRole.values) {
      if (role != UserRole.unsupported && role.wireName == value) {
        return role;
      }
    }
    return UserRole.unsupported;
  }
}
