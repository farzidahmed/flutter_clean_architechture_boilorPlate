import 'package:dio/dio.dart';
import '../error/exceptions.dart';

/// ============================================================
///  ApiService — পুরো app-এর একমাত্র জায়গা যেখান থেকে API call যায়
/// ============================================================
///
/// কেন এটা দরকার?
/// প্রতিটা feature-এর DataSource-এ যদি নিজে নিজে dio.get()/dio.post()
/// কল করে try/catch লেখা হতো, তাহলে ৫টা feature মানে ৫ বার একই
/// error-handling কোড কপি-পেস্ট হতো। তার বদলে এই একটা ক্লাস
/// সবার হয়ে সেই কাজটা করে দেয় — একবার লেখা, সবাই ব্যবহার করে।
///
/// এই ক্লাস আসল response JSON টা **hoobohoo (raw)** parser function-এ
/// পাঠিয়ে দেয় — কোনো auto "data" unwrap করে না। কারণ, আপনার backend-এর
/// প্রতিটা endpoint-এর response shape একরকম না:
///   - Login response-এ token থাকে সরাসরি top-level-এ (data-এর ভেতরে না)
///   - Profile response-এ সব কিছু data-এর ভেতরে থাকে
/// তাই unwrap করার দায়িত্ব প্রতিটা Model-এর নিজের fromJson()-এর উপর
/// ছেড়ে দেওয়া হয়েছে — এটাই সবচেয়ে flexible ও bug-free approach।
class ApiService {
  final Dio dio;
  ApiService(this.dio);

  /// GET request — ডাটা read করার জন্য (যেমন: profile আনা, list আনা)
  ///
  /// [path]            → endpoint path, যেমন '/user/profile'
  /// [queryParameters]  → URL-এর পরে ?key=value আকারে যা যাবে
  /// [parser]          → response-এর raw JSON body নিয়ে সেটাকে
  ///                      আপনার Model ক্লাসে রূপান্তর করে দেয়
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return _parse(response, parser);
    } on DioException catch (e) {
      // dio নিজে যেসব error (timeout, no internet, 4xx/5xx) throw করে,
      // সেগুলোকে আমাদের নিজস্ব ServerException-এ রূপান্তর করা হয় —
      // যাতে বাকি পুরো app শুধু ServerException/Failure নিয়েই কাজ করে,
      // Dio-এর ইন্টারনাল ক্লাস নিয়ে মাথা ঘামাতে না হয়।
      throw _mapError(e);
    }
  }

  /// POST request — ডাটা পাঠানোর জন্য (যেমন: login, form submit, create)
  ///
  /// [data] → body হিসেবে যা পাঠানো হবে, সাধারণত একটা Map
  ///          যেমন: {'email': email, 'password': password}
  Future<T> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.post(path, data: data);
      return _parse(response, parser);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// PUT — সাধারণত existing কিছু আপডেট করতে (যেমন: profile edit)
  Future<T> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.put(path, data: data);
      return _parse(response, parser);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// DELETE — কিছু মুছে ফেলতে (যেমন: account delete, item remove)
  Future<T> delete<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.delete(path, data: data);
      return _parse(response, parser);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// একটা successful HTTP response (status 200-299) এলে এখানে আসে।
  /// response.data (যেটা raw JSON Map) সরাসরি parser-কে দিয়ে দেওয়া হয় —
  /// parser মানে আপনার Model-এর fromJson, যেমন:
  ///   parser: (json) => LoginResponseModel.fromJson(json)
  T _parse<T>(Response response, T Function(dynamic json) parser) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 200 && statusCode < 300) {
      return parser(response.data);
    }
    // status code 200-299 এর বাইরে হলে backend সাধারণত একটা
    // {"message": "..."} পাঠায় — সেটা বের করে ServerException throw করা হয়।
    throw ServerException(
      message: _extractMessage(response.data) ?? 'Unexpected server error',
      statusCode: statusCode,
    );
  }

  /// Dio-এর বিভিন্ন error type-কে মানুষ-পড়তে-পারা Bangla/English
  /// message-এ রূপান্তর করে — UI-তে এই message সরাসরি দেখানো যায়।
  ServerException _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException(message: 'Connection timeout, আবার চেষ্টা করুন');
      case DioExceptionType.connectionError:
        return ServerException(message: 'ইন্টারনেট কানেকশন চেক করুন');
      case DioExceptionType.badResponse:
        // ৪xx/৫xx এলে এখানে আসে — response.data থেকে backend-এর
        // নিজের error message বের করার চেষ্টা করা হয়।
        return ServerException(
          message: _extractMessage(e.response?.data) ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      default:
        return ServerException(message: e.message ?? 'Unexpected error');
    }
  }

  /// backend-এর response body একটা Map হলে তার ভেতর থেকে "message"
  /// key বের করার চেষ্টা করে — না পেলে null রিটার্ন করে, তখন
  /// caller একটা default message ব্যবহার করে।
  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }
    return null;
  }
}
