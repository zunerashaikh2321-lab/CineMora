class UserModel {
  final String userId;
  final String name;
  final String birthdate;
  final String gender;
  final String email;
  final String password;
  final String phoneNumber;
  final String termsAccepted;
  final String profileImage;
  final String createdAt;
  final String resetOtp;

  UserModel({
    required this.userId,
    required this.name,
    required this.birthdate,
    required this.gender,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.termsAccepted,
    required this.profileImage,
    required this.createdAt,
    required this.resetOtp,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      birthdate: json['birthdate']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      termsAccepted: json['terms_accepted']?.toString() ?? '',
      profileImage: json['profile_image']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      resetOtp: json['reset_otp']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'birthdate': birthdate,
      'gender': gender,
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
      'terms_accepted': termsAccepted,
      'profile_image': profileImage,
      'created_at': createdAt,
      'reset_otp': resetOtp,
    };
  }
}