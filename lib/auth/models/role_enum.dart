enum UserRole { admin, operator, view, unknown }

extension UserRoleX on UserRole {
  static UserRole fromString(String val) {
    switch (val) {
      case '1':
      case 'admin':
        return UserRole.admin;
      case '2':
      case 'operator':
        return UserRole.operator;
      case '3':
      case 'view':
        return UserRole.view;
      default:
        return UserRole.unknown;
    }
  }

  String get value {
    switch (this) {
      case UserRole.admin: return 'admin';
      case UserRole.operator: return 'operator';
      default: return 'view';
    }
  }

  String get label {
    switch (this) {
      case UserRole.admin: return 'Administrator';
      case UserRole.operator: return 'Operator Lapangan';
      case UserRole.view: return 'Viewer / Anggota';
      default: return 'Unknown';
    }
  }
}