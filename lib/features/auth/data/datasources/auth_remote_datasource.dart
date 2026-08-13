import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/login_response_model.dart';

/// DataSource-এর কাজ একটাই — actual network call করা এবং raw JSON-কে
/// সঠিক Model-এ রূপান্তর করে দেওয়া। এখানে কোনো business logic
/// (যেমন: token save করা, error কে Failure বানানো) থাকবে না —
/// সেগুলো Repository-র কাজ।
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;
  AuthRemoteDataSourceImpl(this.apiService);

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) {
    // apiService.post() নিজেই DioException handle করে ServerException
    // throw করে দেয় — তাই এখানে try/catch লেখার দরকার নেই।
    //
    // parser callback-এ raw JSON body (পুরোটাই, "data" unwrap ছাড়া)
    // আসে, আর আমরা সেটাকে LoginResponseModel.fromJson দিয়ে parse করছি —
    // এই model-এর ভেতরেই token (top-level) আর data (nested user) দুটোই
    // সঠিকভাবে ধরা পড়ে।
    return apiService.post<LoginResponseModel>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
      parser: (json) => LoginResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
