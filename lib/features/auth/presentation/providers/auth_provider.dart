import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';

// ---- DI wiring: প্রতিটা layer-এর provider, নিচেরটা উপরেরটাকে watch করে ----
// dioProvider → apiServiceProvider (core/providers/core_providers.dart)
//   → authRemoteDataSourceProvider → authRepositoryProvider
//   → loginUseCaseProvider → authControllerProvider (একদম নিচে, UI এটাই ব্যবহার করে)

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(apiServiceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

/// ============================================================
///  AuthController — POST-pattern-এর মূল উদাহরণ
/// ============================================================
///
/// ProfileNotifier (GET)-এর সাথে তুলনা করলে পার্থক্যটা স্পষ্ট হবে:
///  - ProfileNotifier-এর build() নিজে থেকেই fetch করত (page open
///    হওয়া মাত্র)।
///  - এখানে build() শুধু `null` রিটার্ন করে — কিছুই fetch করে না।
///    কারণ login একটা **action**, যেটা user বাটনে চাপ দিলে তবেই
///    ঘটবে, page load হওয়া মাত্র না।
///
/// state-এর টাইপ AsyncValue<UserEntity?> — null মানে এখনো login করা
/// হয়নি, non-null মানে সফলভাবে login হয়ে গেছে।
class AuthController extends AsyncNotifier<UserEntity?> {
  @override
  FutureOr<UserEntity?> build() => null;

  /// UI-এর "লগইন করুন" বাটন থেকে এই method call হয়।
  Future<void> login({required String email, required String password}) async {
    // প্রথমে state-কে loading করে দেওয়া হয় — UI-তে তখন বাটনের বদলে
    // একটা spinner দেখানো হবে (login_page.dart-এ isLoading চেক করে)।
    state = const AsyncValue.loading();

    final result = await ref.read(loginUseCaseProvider)(
      LoginParams(email: email, password: password),
    );

    // Either<Failure, UserEntity> থেকে AsyncValue<UserEntity?>-এ রূপান্তর:
    //  - failure এলে AsyncValue.error() — UI-তে ref.listen() এর error
    //    callback-এ ধরা পড়বে, snackbar দেখানো হবে।
    //  - user এলে AsyncValue.data() — UI-তে ref.listen() এর data
    //    callback-এ ধরা পড়বে, profile page-এ navigate হবে।
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  /// Logout করলে state আবার null করে দেওয়া হয়। চাইলে এখানে
  /// AuthTokenStore.clearToken() ও call করে দিতে পারেন।
  void logout() {
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, UserEntity?>(
  AuthController.new,
);
