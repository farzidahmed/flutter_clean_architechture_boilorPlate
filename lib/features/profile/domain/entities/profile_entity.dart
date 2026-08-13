import 'package:equatable/equatable.dart';
import 'profile_user_entity.dart';

/// Profile GET API-র response-এ শুধু user info থাকে না, সাথে কিছু
/// stats-ও থাকে (total properties, favorites, views — যেটা
/// BashaBari-এর মতো listing app-এ ড্যাশবোর্ডে দেখানো হয়)। তাই এই
/// Entity-তে ProfileUserEntity-কে একটা field হিসেবে nested রাখা
/// হয়েছে, ঠিক যেভাবে backend response-এও nested ছিল।
class ProfileEntity extends Equatable {
  final int? totalProperties;
  final int? totalFavorites;
  final int? totalViews;
  final ProfileUserEntity? user;

  const ProfileEntity({
    this.totalProperties,
    this.totalFavorites,
    this.totalViews,
    this.user,
  });

  @override
  List<Object?> get props => [totalProperties, totalFavorites, totalViews, user];
}
