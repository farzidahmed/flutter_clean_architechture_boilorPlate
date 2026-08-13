import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';

// ---- DI wiring: নিচের প্রতিটা provider উপরেরটাকে watch করে বানানো হয় ----
// dioProvider → apiServiceProvider (core/providers/core_providers.dart-এ আছে)
//   → profileRemoteDataSourceProvider → profileRepositoryProvider
//   → getProfileUseCaseProvider → profileNotifierProvider (একদম নিচে)

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(ref.watch(apiServiceProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

/// ============================================================
///  ProfileNotifier — GET-pattern-এর মূল উদাহরণ
/// ============================================================
///
/// AsyncNotifier<ProfileEntity> extend করার মানে হলো এই Notifier-এর
/// state সবসময় AsyncValue<ProfileEntity> টাইপের — যেটা তিনটা অবস্থার
/// একটাই সময়ে থাকতে পারে: loading, data(ProfileEntity), অথবা
/// error(Object)। UI-তে .when() দিয়ে এই তিনটাই handle করা হয়।
///
/// build() method-টা Riverpod নিজে থেকেই প্রথমবার call করে — অর্থাৎ
/// যখনই কোনো widget প্রথমবার profileNotifierProvider watch করবে,
/// build() চলে API call শুরু হয়ে যাবে। এটাই GET আর POST (auth_provider.dart-
/// এর AuthController) এর মূল পার্থক্য — POST কোনো button click-এ
/// trigger হয়, GET page open হওয়া মাত্রই।
class ProfileNotifier extends AsyncNotifier<ProfileEntity> {
  @override
  Future<ProfileEntity> build() => _fetch();

  /// Pull-to-refresh করলে UI থেকে এই method call হয় — state আগে
  /// loading করে দেওয়া হয় (যাতে UI spinner দেখাতে পারে), তারপর নতুন
  /// করে fetch হয়। AsyncValue.guard() নিজে থেকেই try/catch করে —
  /// error এলে সেটা automatically AsyncValue.error() বানিয়ে দেয়।
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  /// UseCase call করে Either<Failure, ProfileEntity> পাওয়া যায়।
  /// fold() দিয়ে দুটো সম্ভাবনার একটাকে handle করা হয়:
  ///  - বামপাশে (failure) এলে সেটাকে throw করে দেওয়া হয়, যাতে
  ///    AsyncNotifier নিজে থেকেই সেটাকে error state বানিয়ে ফেলে।
  ///  - ডানপাশে (profile) এলে সরাসরি রিটার্ন করা হয় — এটাই success data।
  Future<ProfileEntity> _fetch() async {
    final result = await ref.read(getProfileUseCaseProvider)(const NoParams());
    return result.fold((failure) => throw failure, (profile) => profile);
  }
}

final profileNotifierProvider = AsyncNotifierProvider<ProfileNotifier, ProfileEntity>(
  ProfileNotifier.new,
);
