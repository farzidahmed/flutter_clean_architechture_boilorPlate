import 'package:equatable/equatable.dart';

/// ============================================================
///  ProfileUserEntity — profile-এর ভেতরের ব্যক্তিগত তথ্য
/// ============================================================
///
/// লক্ষ্য করুন — এটা auth/user_entity.dart-এর UserEntity থেকে আলাদা
/// একটা ক্লাস, যদিও দুটোই "user"-এর তথ্য রাখে। কেন আলাদা রাখা হলো?
///  - Login response আর Profile response দুটো ভিন্ন API, ভিন্ন
///    field সেট রিটার্ন করে (login-এ token থাকে, profile-এ dob/
///    address/nid_number ইত্যাদি থাকে)।
///  - দুটোকে জোর করে এক ক্লাসে গুঁজে দিলে ভবিষ্যতে যেকোনো একটা
///    বদলালে আরেকটাও ভেঙে যেতে পারে।
///  - প্রতিটা feature-এর নিজের Entity থাকা Clean Architecture-এর
///    মূল নিয়ম — feature গুলো একে অপরের থেকে independent থাকবে।
///
/// backend অনেক field-এ null/অজানা type পাঠাতে পারে (dob, address,
/// nid_number ইত্যাদি এখনো set না করা থাকলে) — তাই সেগুলো dynamic
/// রাখা হয়েছে, ঠিক যেমন আপনার দেওয়া raw model-এ ছিল। চাইলে ভবিষ্যতে
/// backend থেকে টাইপ নিশ্চিত হলে dynamic-কে String?/int? দিয়ে বদলে
/// নিতে পারবেন — শুধু এই একটা ফাইল বদলালেই চলবে।
class ProfileUserEntity extends Equatable {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final dynamic avatar;
  final dynamic dob;
  final dynamic address;
  final dynamic nidNumber;
  final dynamic religion;
  final dynamic gender;
  final dynamic profession;
  final dynamic divisionId;
  final dynamic districtId;
  final dynamic upazilaId;
  final dynamic whatsappNumber;

  const ProfileUserEntity({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.avatar,
    this.dob,
    this.address,
    this.nidNumber,
    this.religion,
    this.gender,
    this.profession,
    this.divisionId,
    this.districtId,
    this.upazilaId,
    this.whatsappNumber,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        avatar,
        dob,
        address,
        nidNumber,
        religion,
        gender,
        profession,
        divisionId,
        districtId,
        upazilaId,
        whatsappNumber,
      ];
}
