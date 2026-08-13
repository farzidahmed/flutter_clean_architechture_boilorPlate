import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'ইন্টারনেট কানেকশন নেই'));
    }
    try {
      final response = await remoteDataSource.getProfile();

      if (response.data == null) {
        return Left(ServerFailure(message: response.message ?? 'প্রোফাইল লোড করা যায়নি'));
      }

      // Model → Entity রূপান্তর এখানে হচ্ছে, তাই domain/presentation
      // layer কখনো ProfileResponseModel/ProfileUserModel-এর কথা জানবেই না।
      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
