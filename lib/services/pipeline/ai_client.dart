import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/errors.dart';

typedef DelayCallback = Future<void> Function(Duration duration);

class AiClient {
  AiClient({Dio? dio, DelayCallback? delay})
    : _dio = dio ?? Dio(),
      _delay = delay ?? Future<void>.delayed;

  final Dio _dio;
  final DelayCallback _delay;

  Future<String> cleanChunk({
    required int pageNumber,
    required String prompt,
    required String apiKey,
    String geminiModel = 'gemini-2.5-flash',
    List<String> gemmaModels = const <String>[
      'gemma-3-27b-it',
      'gemma-3-12b-it',
      'gemma-3-4b-it',
    ],
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const SettingsException('Google AI Studio API key is missing.');
    }

    if (pageNumber <= 10) {
      return _requestWithRetry(
        model: geminiModel,
        apiKey: apiKey,
        prompt: prompt,
        maxAttempts: 3,
        allowFallback: false,
      );
    }

    for (final String model in gemmaModels) {
      try {
        return await _requestWithRetry(
          model: model,
          apiKey: apiKey,
          prompt: prompt,
          maxAttempts: 1,
          allowFallback: true,
        );
      } on AiException {
        continue;
      }
    }

    await _delay(const Duration(seconds: 30));
    return _requestWithRetry(
      model: gemmaModels.first,
      apiKey: apiKey,
      prompt: prompt,
      maxAttempts: 3,
      allowFallback: false,
    );
  }

  Future<String> _requestWithRetry({
    required String model,
    required String apiKey,
    required String prompt,
    required int maxAttempts,
    required bool allowFallback,
  }) async {
    int attempt = 0;
    while (attempt < maxAttempts) {
      attempt += 1;
      try {
        final Response<Map<String, dynamic>> response = await _dio
            .post<Map<String, dynamic>>(
              '${AppConstants.aiEndpointBase}/$model:generateContent',
              queryParameters: <String, Object?>{'key': apiKey},
              data: <String, Object?>{
                'contents': <Object?>[
                  <String, Object?>{
                    'parts': <Object?>[
                      <String, Object?>{'text': prompt},
                    ],
                  },
                ],
                'generationConfig': <String, Object?>{
                  'temperature': 0.1,
                  'maxOutputTokens': 8192,
                },
              },
              options: Options(
                sendTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 60),
                headers: <String, Object?>{'Content-Type': 'application/json'},
              ),
            );
        final Map<String, dynamic> data = response.data ?? <String, dynamic>{};
        return _extractText(data);
      } on DioException catch (error) {
        final int? statusCode = error.response?.statusCode;
        if (statusCode == 400) {
          return '';
        }
        if (_isTimeout(error) && attempt < maxAttempts) {
          await _delay(const Duration(seconds: 5));
          continue;
        }
        if ((statusCode == 429 || statusCode == 500 || statusCode == 503) &&
            attempt < maxAttempts) {
          await _delay(
            statusCode == 429
                ? const Duration(seconds: 30)
                : const Duration(seconds: 10),
          );
          continue;
        }
        if (allowFallback) {
          throw AiException(
            'Model fallback required.',
            model: model,
            statusCode: statusCode,
          );
        }
        throw AiException(
          error.message ?? 'AI request failed.',
          model: model,
          statusCode: statusCode,
        );
      }
    }
    throw AiException('AI request failed after retries.', model: model);
  }

  String _extractText(Map<String, dynamic> data) {
    final List<dynamic> candidates =
        (data['candidates'] as List<dynamic>?) ?? <dynamic>[];
    if (candidates.isEmpty) {
      return '';
    }
    final Map<String, dynamic> candidate =
        candidates.first as Map<String, dynamic>;
    final Map<String, dynamic> content =
        (candidate['content'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final List<dynamic> parts =
        (content['parts'] as List<dynamic>?) ?? <dynamic>[];
    if (parts.isEmpty) {
      return '';
    }
    final Map<String, dynamic> part = parts.first as Map<String, dynamic>;
    return part['text'] as String? ?? '';
  }

  bool _isTimeout(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError;
  }
}
