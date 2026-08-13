import 'package:equatable/equatable.dart';

/// ============================================================
///  UserEntity — Domain layer-এর "logged-in user"
/// ============================================================
///
/// এটা আসল API response না — এটা হলো app-এর ভেতরে ব্যবহারযোগ্য
/// একটা পরিষ্কার (clean) object। Login response-এ token
/// top-level-এ থাকলেও, আর user-এর তথ্য "data" এর ভেতরে থাকলেও,
/// এই Entity-তে এসে সব একসাথে flatten হয়ে যায় — যাতে UI থেকে
/// user.token, user.name সহজে access করা যায়, কোনো nested
/// data.something লাগে না।
///
/// সব field nullable রাখা হয়েছে কারণ backend মাঝে মাঝে কিছু field
/// null পাঠাতে পারে (avatar না থাকলে ইত্যাদি) — UI-তে ব্যবহারের সময়
/// `user.name ?? 'অজানা'` এভাবে default দিয়ে নেবেন।
class UserEntity extends Equatable {
  final int? id;
  final String? name;
  final String? email;
  final String? avatar;
  final DateTime? otpVerifiedAt;
  final String? lastActivityAt;

  /// login সফল হলে backend যে Bearer token দেয় — পরবর্তী প্রতিটা
  /// authenticated API call-এ এই token attach করা হবে
  /// (AuthTokenStore-এর মাধ্যমে, DioClient-এর interceptor-এ)
  final String? token;

  /// token কতক্ষণ পর expire হবে (সেকেন্ডে) — future-এ auto-refresh
  /// বা auto-logout logic বানাতে কাজে লাগবে
  final int? expiresIn;

  const UserEntity({
    this.id,
    this.name,
    this.email,
    this.avatar,
    this.otpVerifiedAt,
    this.lastActivityAt,
    this.token,
    this.expiresIn,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatar,
        otpVerifiedAt,
        lastActivityAt,
        token,
        expiresIn,
      ];
}
