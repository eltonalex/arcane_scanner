import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../../domain/models/card_identification.dart';
import 'ai_identifier.dart';

class GeminiIdentifier implements AiCardIdentifier {
  GeminiIdentifier({required this.apiKey, Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 45),
        ));

  final String apiKey;
  final Dio _dio;

  static const _model = 'gemini-2.5-flash';

  @override
  Future<Result<CardIdentification>> identify(Uint8List jpegBytes) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$_model:generateContent',
        options: Options(headers: {
          'x-goog-api-key': apiKey,
          'Content-Type': 'application/json',
        }),
        data: {
          'systemInstruction': {
            'parts': [
              {'text': aiSystemPrompt},
            ],
          },
          'contents': [
            {
              'parts': [
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Encode(jpegBytes),
                  },
                },
              ],
            },
          ],
          'generationConfig': {'temperature': 0, 'maxOutputTokens': 300},
        },
      );
      final text = response.data?['candidates']?[0]?['content']?['parts']
              ?[0]?['text'] as String? ??
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
