import 'package:arcane_scanner/data/ai/ai_identifier.dart';
import 'package:arcane_scanner/data/ocr/ocr_text_parser.dart';
import 'package:arcane_scanner/domain/models/card_identification.dart';
import 'package:arcane_scanner/domain/models/language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseOcrLines', () {
    test('carta moderna: nome no topo, set+número+idioma no rodapé', () {
      final result = parseOcrLines([
        'Lightning Bolt',
        'Instant',
        'Lightning Bolt deals 3 damage to any target.',
        '123/302 R',
        'NEO • EN',
        'Illus. Christopher Moeller',
      ]);
      expect(result.name, 'Lightning Bolt');
      expect(result.set, 'NEO');
      expect(result.collectorNumber, '123');
      expect(result.language, Language.en);
      expect(result.confidence, greaterThanOrEqualTo(0.9));
    });

    test('remove zeros à esquerda do collector number', () {
      final result = parseOcrLines(['Sol Ring', '0007/302 U', 'MH2 - PT']);
      expect(result.collectorNumber, '7');
      expect(result.set, 'MH2');
      expect(result.language, Language.pt);
    });

    test('idioma JA (impresso) é mapeado para JP', () {
      final result = parseOcrLines(['カード', '001/100 C', 'NEO JA']);
      expect(result.language, Language.jp);
    });

    test('carta antiga: só o nome — confiança média', () {
      final result = parseOcrLines([
        'Counterspell',
        'Interrupt',
        'Counter target spell.',
      ]);
      expect(result.name, 'Counterspell');
      expect(result.set, '');
      expect(result.confidence, closeTo(0.5, 0.001));
    });

    test('imagem sem texto útil: confiança zero', () {
      final result = parseOcrLines(['12', '&*%']);
      expect(result.isEmpty, isTrue);
      expect(result.confidence, 0);
    });
  });

  group('parseAiResponse', () {
    test('JSON limpo', () {
      final result = parseAiResponse(
        '{"name":"Sol Ring","set":"c21","collector_number":"263",'
        '"confidence":0.95,"notes":"clear photo"}',
      );
      final id = result.when(ok: (v) => v, err: (f) => fail(f.message));
      expect(id.name, 'Sol Ring');
      expect(id.set, 'c21');
      expect(id.collectorNumber, '263');
      expect(id.confidence, 0.95);
    });

    test('tolera cercas de markdown apesar do prompt', () {
      final result = parseAiResponse(
        'Aqui está:\n```json\n{"name":"Opt","set":"","collector_number":"",'
        '"confidence":0.4,"notes":""}\n```',
      );
      final id = result.when(ok: (v) => v, err: (f) => fail(f.message));
      expect(id.name, 'Opt');
      expect(id.hasSetAndNumber, isFalse);
    });

    test('collector_number numérico (sem aspas) vira string', () {
      final result = parseAiResponse(
        '{"name":"Opt","set":"xln","collector_number":65,'
        '"confidence":0.8,"notes":""}',
      );
      final id = result.when(ok: (v) => v, err: (f) => fail(f.message));
      expect(id.collectorNumber, '65');
    });

    test('resposta sem JSON vira falha amigável', () {
      final result = parseAiResponse('Desculpe, não consigo ajudar.');
      expect(result.isOk, isFalse);
    });

    test('confidence fora do intervalo é limitada a 0..1', () {
      final result = parseAiResponse(
        '{"name":"X","set":"","collector_number":"","confidence":7,'
        '"notes":""}',
      );
      final id = result.when(ok: (v) => v, err: (f) => fail(f.message));
      expect(id.confidence, 1.0);
    });
  });

  group('mergeOcrClues', () {
    test('rodapé tem prioridade em set e collector number', () {
      final card = const CardIdentification(
        name: 'Lightning Bolt',
        set: 'NEQ', // OCR da carta inteira errou o set
        collectorNumber: '',
        source: IdentificationSource.ocr,
      );
      final footer = const CardIdentification(
        name: '',
        set: 'NEO', // rodapé em alta resolução acertou
        collectorNumber: '123',
        language: Language.pt,
        source: IdentificationSource.ocr,
      );
      final merged = mergeOcrClues(card: card, footer: footer);
      expect(merged.name, 'Lightning Bolt'); // nome vem da carta
      expect(merged.set, 'NEO'); // set vem do rodapé
      expect(merged.collectorNumber, '123');
      expect(merged.language, Language.pt);
      expect(merged.confidence, greaterThanOrEqualTo(0.9));
    });

    test('cai para os dados da carta quando o rodapé vem vazio', () {
      final card = const CardIdentification(
        name: 'Sol Ring',
        set: 'c21',
        collectorNumber: '263',
        source: IdentificationSource.ocr,
      );
      final footer =
          const CardIdentification(source: IdentificationSource.ocr);
      final merged = mergeOcrClues(card: card, footer: footer);
      expect(merged.set, 'c21');
      expect(merged.collectorNumber, '263');
    });
  });
}
