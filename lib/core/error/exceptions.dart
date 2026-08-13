/// Data layer-এ throw হয়, Repository এগুলোকে catch করে Failure-এ map করে।
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException({required this.message, this.statusCode});
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});
}
