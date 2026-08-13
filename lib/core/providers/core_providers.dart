import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_service.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

/// পুরো app-এর জন্য একটাই Dio instance — সব feature এটাই শেয়ার করে।
final dioProvider = Provider<Dio>((ref) => DioClient.create());

/// পুরো app-এর জন্য একটাই ApiService — সব DataSource এটাই ব্যবহার করে।
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(dioProvider));
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});
