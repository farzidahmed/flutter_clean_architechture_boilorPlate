import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// এটা শুধুই একটা contract (abstract class) — এখানে কোনো implementation
/// নেই। Domain layer শুধু জানে "login() call করলে Either<Failure,
/// UserEntity> পাওয়া যাবে" — কীভাবে (Dio? http? Laravel? Firebase?)
/// সেই তথ্য implementation (AuthRepositoryImpl)-এ থাকে, domain layer
/// সেটা জানেই না। এই জন্যই Domain layer টেস্ট করা এত সহজ — আসল API
/// call ছাড়াই একটা fake/mock Repository বসিয়ে UseCase টেস্ট করা যায়।
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });
}
