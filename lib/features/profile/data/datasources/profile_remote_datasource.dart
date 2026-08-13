import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/profile_response_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileResponseModel> getProfile();
}

/// GET call — auth_remote_datasource.dart-এর post() এর জায়গায় এখানে
/// get() ব্যবহার হচ্ছে, বাকি প্যাটার্ন (parser দিয়ে raw JSON-কে Model-এ
/// রূপান্তর) একদম একই। এটাই common ApiService reuse করার সুবিধা —
/// GET হোক বা POST, DataSource layer-এ লেখার ধরন সবসময় একরকম।
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService apiService;
  ProfileRemoteDataSourceImpl(this.apiService);

  @override
  Future<ProfileResponseModel> getProfile() {
    return apiService.get<ProfileResponseModel>(
      ApiEndpoints.profile,
      parser: (json) => ProfileResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
