enum UserRole {
  endUser,
  operator,
  administrator,
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.endUser:
        return 'EndUser';
      case UserRole.operator:
        return 'Operator';
      case UserRole.administrator:
        return 'Administrator';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.endUser,
    );
  }
}
