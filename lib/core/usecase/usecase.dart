import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// প্রতিটা UseCase এই contract মেনে চলে — Type হলো success-এ কী রিটার্ন
/// হবে, Params হলো input। GET-এর মতো যেখানে input লাগে না, সেখানে
/// Params-এর জায়গায় NoParams ব্যবহার হবে।
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
