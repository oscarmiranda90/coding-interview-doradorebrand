import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class DioClient {
  DioClient._();

  static Dio create() => Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
