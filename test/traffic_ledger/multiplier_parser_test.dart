import 'package:fl_clash/traffic_ledger/multiplier_parser.dart';
import 'package:test/test.dart';

void main() {
  group('MultiplierParser.parse', () {
    test('returns null for empty name', () {
      expect(MultiplierParser.parse(''), isNull);
      expect(MultiplierParser.parse('   '), isNull);
    });

    test('returns null when no multiplier marker', () {
      expect(MultiplierParser.parse('Hong Kong 01'), isNull);
      expect(MultiplierParser.parse('日本 东京'), isNull);
    });

    group('倍率: N form', () {
      test('parses 倍率: 2', () {
        expect(MultiplierParser.parse('节点 倍率: 2'), 2.0);
      });
      test('parses 倍率:2 (no space)', () {
        expect(MultiplierParser.parse('节点 倍率:2'), 2.0);
      });
      test('parses 倍率：2 (fullwidth colon)', () {
        expect(MultiplierParser.parse('节点 倍率：2'), 2.0);
      });
      test('parses 倍率 2 (no colon)', () {
        expect(MultiplierParser.parse('节点 倍率 2'), 2.0);
      });
      test('parses 倍率=2', () {
        expect(MultiplierParser.parse('节点 倍率=2'), 2.0);
      });
      test('parses decimal 倍率: 1.5', () {
        expect(MultiplierParser.parse('节点 倍率: 1.5'), 1.5);
      });
    });

    group('Nx suffix form', () {
      test('parses 2x', () {
        expect(MultiplierParser.parse('Hong Kong 2x'), 2.0);
      });
      test('parses 2X (uppercase)', () {
        expect(MultiplierParser.parse('Hong Kong 2X'), 2.0);
      });
      test('parses 2× (multiplication sign U+00D7)', () {
        expect(MultiplierParser.parse('Hong Kong 2×'), 2.0);
      });
      test('parses 2 x (space before x)', () {
        expect(MultiplierParser.parse('Hong Kong 2 x'), 2.0);
      });
      test('parses 1.5x decimal', () {
        expect(MultiplierParser.parse('节点 1.5x'), 1.5);
      });
    });

    group('N倍 suffix form', () {
      test('parses 2倍', () {
        expect(MultiplierParser.parse('香港 2倍'), 2.0);
      });
      test('parses 2 倍 (space)', () {
        expect(MultiplierParser.parse('香港 2 倍'), 2.0);
      });
      test('parses 0.5倍 decimal', () {
        expect(MultiplierParser.parse('香港 0.5倍'), 0.5);
      });
    });

    group('xN prefix form', () {
      test('parses x2', () {
        expect(MultiplierParser.parse('x2 香港'), 2.0);
      });
      test('parses ×2', () {
        expect(MultiplierParser.parse('×2 香港'), 2.0);
      });
    });

    group('validity bounds', () {
      test('rejects zero', () {
        expect(MultiplierParser.parse('节点 0x'), isNull);
        expect(MultiplierParser.parse('节点 倍率: 0'), isNull);
      });
      test('rejects negative via regex (no match)', () {
        expect(MultiplierParser.parse('节点 -1x'), isNull);
      });
      test('rejects absurdly large value', () {
        expect(MultiplierParser.parse('节点 999x'), isNull);
      });
    });
  });

  group('MultiplierParser.parseOrDefault', () {
    test('returns parsed value when recognized', () {
      expect(MultiplierParser.parseOrDefault('香港 2x'), 2.0);
    });
    test('returns default 1.0 when not recognized', () {
      expect(MultiplierParser.parseOrDefault('香港 01'), 1.0);
    });
    test('returns custom default when not recognized', () {
      expect(
        MultiplierParser.parseOrDefault('香港 01', defaultValue: 0.5),
        0.5,
      );
    });
  });

  group('MultiplierParser.approxEquals', () {
    test('equal values', () {
      expect(MultiplierParser.approxEquals(1.0, 1.0), isTrue);
    });
    test('tiny delta within epsilon', () {
      expect(
        MultiplierParser.approxEquals(1.0, 1.0 + 1e-12),
        isTrue,
      );
    });
    test('large delta not equal', () {
      expect(MultiplierParser.approxEquals(1.0, 1.1), isFalse);
    });
  });
}
