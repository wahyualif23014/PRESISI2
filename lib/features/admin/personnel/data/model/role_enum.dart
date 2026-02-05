enum UserRole {
  admin,
  view,
  polres,
  polsek,
  unknown // Fallback jika ada role baru
}

extension UserRoleX on UserRole {
  static UserRole fromString(String val) {
    switch (val.toLowerCase()) {
      case 'admin': return UserRole.admin;
      case 'view': return UserRole.view;
      case 'polres': return UserRole.polres;
      case 'polsek': return UserRole.polsek;
      default: return UserRole.unknown; // Atau default ke UserRole.view
    }
  }

  // Konversi dari Enum ke String (untuk dikirim ke Backend/UI)
  String get label {
    switch (this) {
      case UserRole.admin: return 'admin';
      case UserRole.view: return 'view';
      case UserRole.polres: return 'polres';
      case UserRole.polsek: return 'polsek';
      default: return 'view';
    }
  }
}