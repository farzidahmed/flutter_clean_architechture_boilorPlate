import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// UseCase মানে "একটা single business action"। এই ক্লাসের কাজ শুধু
/// একটাই — Repository-কে call করে login করা। এত ছোট কাজের জন্য
/// আলাদা ক্লাস কেন?
///  - UI layer সরাসরি Repository চেনে না, শুধু UseCase চেনে —
///    তাই UI আর data layer-এর মধ্যে coupling কমে যায়।
///  - প্রতিটা UseCase individually unit-test করা যায়।
///  - ভবিষ্যতে login-এর আগে/পরে extra logic (analytics event পাঠানো, validation) লাগলে সেটা এখানে যোগ হবে, Repository-তে না।
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}

/// UseCase-এর input — শুধু email আর password এখানে বান্ডিল করা।
/// Equatable extend করার কারণে দুটো LoginParams object একই মান হলে == দিয়ে compare করলে true আসবে (Riverpod/Bloc-এ কাজে লাগে)।
class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
