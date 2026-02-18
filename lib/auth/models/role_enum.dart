enum UserRole { admin, operator, view, unknown }

extension UserRoleX on UserRole {
  static UserRole fromString(String val) {
    switch (val) {
      case '1': return UserRole.admin;
      case '2': return UserRole.operator;
      case '3': return UserRole.view;
      default: return UserRole.unknown;
    }
  }

  String get value {
    switch (this) {
      case UserRole.admin: return '1';
      case UserRole.operator: return '2';
      default: return '3';
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