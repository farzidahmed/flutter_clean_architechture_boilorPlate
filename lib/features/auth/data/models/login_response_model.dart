import 'dart:convert';
import '../../domain/entities/user_entity.dart';

/// ============================================================
///  LoginResponseModel — Login API-র raw JSON-এর hoobohoo প্রতিরূপ
/// ============================================================
///
/// এই ক্লাসটা আপনার backend যেভাবে response পাঠায় ঠিক সেভাবেই গঠন করা:
///
/// {
///   "status": true,
///   "message": "...",
///   "code": 200,
///   "expires_in": 3600,
///   "token": "xxxxx",              ← লক্ষ্য করুন: top-level-এ, data-এর ভেতরে না
///   "data": {
///       "id": 1, "name": "...", "email": "...", "avatar": null,
///       "otp_verified_at": "2026-01-01T10:00:00Z",
///       "last_activity_at": "..."
///   }
/// }
///
/// Model আর Entity কেন আলাদা?
/// - Model (এই ফাইল) জানে API response-এর exact shape — key নাম
///   ভুল থাকলে, বা backend snake_case ব্যবহার করলে, সব সামলানোর
///   দায়িত্ব এখানেই।
/// - Entity (user_entity.dart) জানে না API response কেমন দেখতে —
///   সে শুধু "একজন logged-in user"-এর প্রয়োজনীয় তথ্য রাখে।
/// এই আলাদা করার ফলে backend response বদলালে শুধু এই Model ফাইলটা
/// বদলাতে হবে, বাকি পুরো app (UI, state, business logic) অক্ষত থাকবে।
class LoginResponseModel {
  final bool? status;
  final String? message;
  final int? code;
  final int? expiresIn;
  final String? token;
  final LoginUserDataModel? data;

  LoginResponseModel({
    this.status,
    this.message,
    this.code,
    this.expiresIn,
    this.token,
    this.data,
  });

  /// String (raw JSON text) থেকে সরাসরি বানাতে চাইলে এটা ব্যবহার হয়
  /// (সাধারণত dio ব্যবহার করলে এটা লাগে না, dio নিজেই decode করে দেয়)
  factory LoginResponseModel.fromRawJson(String str) =>
      LoginResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  /// backend থেকে আসা Map<String, dynamic> কে এই ক্লাসে রূপান্তর করে।
  /// json["key"] দিয়ে প্রতিটা field বের করা হচ্ছে — key নামগুলো
  /// backend-এ যা আছে ঠিক তাই (snake_case) বসাতে হবে।
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        status: json["status"],
        message: json["message"],
        code: json["code"],
        expiresIn: json["expires_in"],
        token: json["token"],
        data: json["data"] == null
            ? null
            : LoginUserDataModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "code": code,
        "expires_in": expiresIn,
        "token": token,
        "data": data?.toJson(),
      };

  /// **এইটাই সবচেয়ে গুরুত্বপূর্ণ method** — Model থেকে domain-এর
  /// UserEntity বানায়। top-level token/expiresIn আর nested data-এর
  /// user info — সব এখানে একসাথে flatten হয়ে যায়। এই conversion-টা
  /// Repository layer থেকে কল হবে (data থেকে domain-এ crossing করার সময়)।
  UserEntity toEntity() {
    return UserEntity(
      id: data?.id,
      name: data?.name,
      email: data?.email,
      avatar: data?.avatar?.toString(),
      otpVerifiedAt: data?.otpVerifiedAt,
      lastActivityAt: data?.lastActivityAt,
      token: token,
      expiresIn: expiresIn,
    );
  }
}

/// Login response-এর ভেতরের "data" object — এটা আলাদা ক্লাস করার
/// কারণ backend response nested, তাই আমাদের model-ও nested হওয়া উচিত।
class LoginUserDataModel {
  final int? id;
  final String? name;
  final String? email;

  /// backend এখানে অনেক সময় null, string, বা অন্য কিছু পাঠাতে পারে
  /// (avatar না থাকলে null) — তাই টাইপ নিশ্চিত না হলে dynamic রাখাই
  /// নিরাপদ, পরে .toString() করে ব্যবহার করবেন।
  final dynamic avatar;

  final DateTime? otpVerifiedAt;
  final String? lastActivityAt;

  LoginUserDataModel({
    this.id,
    this.name,
    this.email,
    this.avatar,
    this.otpVerifiedAt,
    this.lastActivityAt,
  });

  factory LoginUserDataModel.fromJson(Map<String, dynamic> json) =>
      LoginUserDataModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        avatar: json["avatar"],
        // DateTime.parse ISO string ("2026-01-01T10:00:00Z") থেকে
        // DateTime object বানায় — null হলে চেক করে null-ই রাখা হয়,
        // নাহলে DateTime.parse(null) crash করবে।
        otpVerifiedAt: json["otp_verified_at"] == null
            ? null
            : DateTime.parse(json["otp_verified_at"]),
        lastActivityAt: json["last_activity_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "avatar": avatar,
        "otp_verified_at": otpVerifiedAt?.toIso8601String(),
        "last_activity_at": lastActivityAt,
      };
}
