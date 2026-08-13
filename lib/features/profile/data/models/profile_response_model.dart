import 'dart:convert';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/profile_user_entity.dart';

/// ============================================================
///  ProfileResponseModel — Profile GET API-র raw JSON প্রতিরূপ
/// ============================================================
///
/// backend response shape:
/// {
///   "status": true, "message": "...", "code": 200,
///   "data": {
///     "total_properties": 5, "total_favorites": 2, "total_views": 120,
///     "user": {
///        "id": 1, "name": "...", "phone": "...", "email": "...",
///        "avatar": null, "dob": null, "address": null, ...
///     }
///   }
/// }
///
/// এই পুরো response-টা তিন স্তরে ভাগ করা হয়েছে (তিনটা ক্লাস), ঠিক
/// backend JSON-এর গঠন অনুযায়ী:
///   ProfileResponseModel  → পুরো envelope (status/message/code/data)
///     └─ ProfileDataModel → data-এর ভেতরের stats + user
///          └─ ProfileUserModel → user-এর ব্যক্তিগত তথ্য
class ProfileResponseModel {
  final bool? status;
  final String? message;
  final int? code;
  final ProfileDataModel? data;

  ProfileResponseModel({this.status, this.message, this.code, this.data});

  factory ProfileResponseModel.fromRawJson(String str) =>
      ProfileResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      ProfileResponseModel(
        status: json["status"],
        message: json["message"],
        code: json["code"],
        data: json["data"] == null ? null : ProfileDataModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "code": code,
        "data": data?.toJson(),
      };

  /// Model → Entity রূপান্তর। এখানে data null থাকলে খালি ProfileEntity
  /// রিটার্ন হয় (crash না করে) — Repository layer চাইলে data null
  /// হওয়াটাকে আলাদাভাবে Failure হিসেবেও ধরতে পারে।
  ProfileEntity toEntity() {
    return ProfileEntity(
      totalProperties: data?.totalProperties,
      totalFavorites: data?.totalFavorites,
      totalViews: data?.totalViews,
      user: data?.user?.toEntity(),
    );
  }
}

class ProfileDataModel {
  final int? totalProperties;
  final int? totalFavorites;
  final int? totalViews;
  final ProfileUserModel? user;

  ProfileDataModel({
    this.totalProperties,
    this.totalFavorites,
    this.totalViews,
    this.user,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) => ProfileDataModel(
        totalProperties: json["total_properties"],
        totalFavorites: json["total_favorites"],
        totalViews: json["total_views"],
        user: json["user"] == null ? null : ProfileUserModel.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "total_properties": totalProperties,
        "total_favorites": totalFavorites,
        "total_views": totalViews,
        "user": user?.toJson(),
      };
}

class ProfileUserModel {
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

  ProfileUserModel({
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

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) => ProfileUserModel(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        avatar: json["avatar"],
        dob: json["dob"],
        address: json["address"],
        nidNumber: json["nid_number"],
        religion: json["religion"],
        gender: json["gender"],
        profession: json["profession"],
        divisionId: json["division_id"],
        districtId: json["district_id"],
        upazilaId: json["upazila_id"],
        whatsappNumber: json["whatsapp_number"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "avatar": avatar,
        "dob": dob,
        "address": address,
        "nid_number": nidNumber,
        "religion": religion,
        "gender": gender,
        "profession": profession,
        "division_id": divisionId,
        "district_id": districtId,
        "upazila_id": upazilaId,
        "whatsapp_number": whatsappNumber,
      };

  /// nested Model → nested Entity রূপান্তর — প্রতিটা field হুবহু copy
  /// হচ্ছে, কারণ এখানে কোনো data-transformation লাগছে না। যদি
  /// ভবিষ্যতে backend-এর key নাম বদলায়, শুধু এই একটা জায়গা বদলালেই
  /// পুরো app কাজ করবে।
  ProfileUserEntity toEntity() {
    return ProfileUserEntity(
      id: id,
      name: name,
      phone: phone,
      email: email,
      avatar: avatar,
      dob: dob,
      address: address,
      nidNumber: nidNumber,
      religion: religion,
      gender: gender,
      profession: profession,
      divisionId: divisionId,
      districtId: districtId,
      upazilaId: upazilaId,
      whatsappNumber: whatsappNumber,
    );
  }
}
