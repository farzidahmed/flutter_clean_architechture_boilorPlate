import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Repository-র কাজ তিনটা:
///  ১) নেট কানেকশন আছে কিনা চেক করা
///  ২) DataSource কল করা এবং Exception এলে সেটাকে Failure-এ রূপান্তর করা
///  ৩) success হলে token save করা এবং Model-কে Entity-তে রূপান্তর করে
///     domain layer-এ ফেরত পাঠানো (Either<Failure, UserEntity>)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'ইন্টারনেট কানেকশন নেই'));
    }
    try {
      final response = await remoteDataSource.login(email: email, password: password);

      // backend "status": false পাঠাতে পারে কিন্তু HTTP code 200-ই থাকতে
      // পারে (কিছু API এভাবে করে) — তাই status field-টাও চেক করা ভালো
      // অভ্যাস। token বা data না থাকলে সেটাকেও invalid response ধরা হচ্ছে।
      if (response.token == null || response.data == null) {
        return Left(ServerFailure(message: response.message ?? 'লগইন ব্যর্থ হয়েছে'));
      }

      // login সফল — token টা centralized store-এ save করা হচ্ছে,
      // যাতে DioClient-এর interceptor পরবর্তী প্রতিটা authenticated
      // request-এ এটা automatically attach করে দেয়।
      AuthTokenStore.setToken(response.token!);

      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
