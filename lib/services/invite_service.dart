// lib/services/invite_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InviteService {
  final Dio _dio;
  InviteService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 12),
              headers: {'content-type': 'application/json'},
            ),
          );

  /// Sends an invite email through the Lambda Function URL.
  /// If functionUrl is null/empty, it falls back to .env FUNCTION_URL.
  Future<void> sendInviteEmail({
    required String email,
    required String acceptUrl,
    String? functionUrl,
  }) async {
    final url = (functionUrl?.trim().isNotEmpty ?? false)
        ? functionUrl!.trim()
        : (dotenv.env['FUNCTION_URL'] ?? '').trim();

    if (url.isEmpty) {
      throw Exception('FUNCTION_URL is missing. Provide it or set it in .env');
    }

    try {
      final res = await _dio.post(
        url,
        data: {'email': email.trim().toLowerCase(), 'url': acceptUrl.trim()},
      );

      if (res.statusCode != 200) {
        throw Exception('Mailer error [${res.statusCode}]: ${res.data}');
      }
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final data = e.response?.data;
      throw Exception('Mailer request failed [${code ?? 'NO_CODE'}]: $data');
    }
  }
}
