import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// GET request-এ কোনো input লাগে না (শুধু logged-in user-এর token
/// দিয়েই backend চিনে ফেলে কার profile আনতে হবে) — তাই Params-এর
/// জায়গায় NoParams ব্যবহার হচ্ছে।
class GetProfileUseCase implements UseCase<ProfileEntity, NoParams> {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(NoParams params) {
    return repository.getProfile();
  }
}
