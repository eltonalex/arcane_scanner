import 'package:dio/dio.dart';

import '../core/result.dart';
import '../domain/models/scryfall_card.dart';

/// Cliente da API pública do Scryfall.
/// Docs: https://scryfall.com/docs/api
class ScryfallApi {
  ScryfallApi({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.scryfall.com',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  // Exigidos pela política do Scryfall:
                  'User-Agent': 'ArcaneScannerFlutter/1.0',
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;

  /// Busca exata por edição + collector number (mais precisa).
  Future<Result<ScryfallCard>> byCodeAndNumber(
    String setCode,
    String collectorNumber,
  ) =>
      _get(
        '/cards/${setCode.toLowerCase().trim()}'
        '/${collectorNumber.trim()}',
        notFoundMessage:
            'Nenhuma carta encontrada para $setCode #$collectorNumber.',
      );

  /// Fallback: busca fuzzy pelo nome (tolera erros de OCR).
  Future<Result<ScryfallCard>> byFuzzyName(String name) => _get(
        '/cards/named',
        query: {'fuzzy': name.trim()},
        notFoundMessage:
            'Nenhuma carta encontrada parecida com "$name".',
      );

  Future<Result<ScryfallCard>> _get(
    String path, {
    Map<String, dynamic>? query,
    required String notFoundMessage,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
      );
      return Result.ok(ScryfallCard.fromJson(response.data!));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.err(AppFailure(notFoundMessage, cause: e));
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return Result.err(AppFailure(
          'Sem conexão com o Scryfall. Verifique sua internet e tente de novo.',
          cause: e,
        ));
      }
      return Result.err(AppFailure(
        'O Scryfall respondeu com um erro inesperado. Tente novamente.',
        cause: e,
      ));
    } catch (e) {
      return Result.err(AppFailure(
        'Não foi possível interpretar a resposta do Scryfall.',
        cause: e,
      ));
    }
  }
}
