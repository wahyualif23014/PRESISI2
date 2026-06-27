class ApiConfig {
  // Gunakan 'localhost' jika memakai USB Debugging + 'adb reverse tcp:8080 tcp:8080'
  // Gunakan 'localhost' karena Anda sudah sukses menjalankan 'adb reverse tcp:8080 tcp:8080'
  static const String baseUrl = 'http://localhost:8080';

  static const String apiBaseUrl = '$baseUrl/api';
  static const String imageBaseUrl = '$baseUrl/uploads/';
}
