import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../../domain/models/card_identification.dart';
import 'ai_identifier.dart';

class AnthropicIdentifier implements AiCardIdentifier {
  AnthropicIdentifier({required this.apiKey, Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 45),
        ));

  final String apiKey;
  final Dio _dio;

  static const _model = 'claude-sonnet-4-5';

  @override
  Future<Result<CardIdentification>> identify(Uint8List jpegBytes) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.anthropic.com/v1/messages',
        options: Options(headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        }),
        data: {
          'model': _model,
          'max_tokens': 300,
          'system': aiSystemPrompt,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': 'image/jpeg',
                    'data': base64Encode(jpegBytes),
                  },
                },
              ],
            },
          ],
        },
      );
      final content = response.data?['content'] as List?;
      final text = content
              ?.map((b) => b is Map ? (b['text'] as String? ?? '') : '')
              .join() ??
          '';
      return parseAiResponse(text);
    } on DioException catch (e) {
      return Result.err(
          aiHttpFailure(e, statusCode: e.response?.statusCode));
    } catch (e) {
      return Result.err(aiHttpFailure(e));
    }
  }
}
