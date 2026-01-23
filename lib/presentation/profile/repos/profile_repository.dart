import '../models/profile_model.dart';

class ProfileRepository {
  ProfileModel getProfileData() {
    return ProfileModel(
      fullName: "Dio Vladika",
      nrp: "039302004",
      position: "Operator Biro SDM",
      location: "Polda Jawa Timur",
      imageUrl:
          "assets/police_avatar.png", // Ganti dengan path asset Anda nanti
    );
  }

  Future<bool> updateProfileData(ProfileModel newProfile) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
