import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../../domain/models/card_identification.dart';
import 'ai_identifier.dart';

class OpenAiIdentifier implements AiCardIdentifier {
  OpenAiIdentifier({required this.apiKey, Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 45),
        ));

  final String apiKey;
  final Dio _dio;

  static const _model = 'gpt-4o-mini';

  @override
  Future<Result<CardIdentification>> identify(Uint8List jpegBytes) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.openai.com/v1/chat/completions',
        options: Options(headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        }),
        data: {
          'model': _model,
          'max_tokens': 300,
          'temperature': 0,
          'messages': [
            {'role': 'system', 'content': aiSystemPrompt},
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image_url',
                  'image_url': {
                    'url':
                        'data:image/jpeg;base64,${base64Encode(jpegBytes)}',
                  },
                },
              ],
            },
          ],
        },
      );
      final text = response.data?['choices']?[0]?['message']?['content']
              as String? ??
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
