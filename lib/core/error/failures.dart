import 'package:equatable/equatable.dart';

/// সব Failure এই ক্লাস থেকে extend হবে।
/// Domain/Presentation layer শুধু Failure চেনে — Exception চেনে না।
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// API থেকে 4xx/5xx বা backend error message এলে
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// ইন্টারনেট কানেকশন না থাকলে
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.statusCode});
}

/// Local cache/storage read/write ব্যর্থ হলে
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.statusCode});
}

/// অপ্রত্যাশিত/অজানা error
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.statusCode});
}
