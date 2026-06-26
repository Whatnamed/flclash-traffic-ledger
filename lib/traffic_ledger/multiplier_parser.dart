import 'dart:math';

/// 节点倍率解析器。从节点名识别 `2x`、`2×`、`2倍`、`倍率: 2` 等明确倍率。
/// 未识别倍率默认 1×。
class MultiplierParser {
  const MultiplierParser._();

  /// 从节点名解析倍率。返回 null 表示未识别（调用方应使用默认 1×）。
  static double? parse(String nodeName) {
    final trimmed = nodeName.trim();
    if (trimmed.isEmpty) return null;

    // 1) "倍率: 2" / "倍率:2" / "倍率 2" / "倍率=2" / "倍率：2"
    final rateColon = RegExp(r'倍率\s*[:：=]?\s*([0-9]+(?:\.[0-9]+)?)');
    final m1 = rateColon.firstMatch(trimmed);
    if (m1 != null) {
      final v = double.tryParse(m1.group(1)!);
      if (_isValidMultiplier(v)) return v;
    }

    // 2) "2x" / "2 x" / "2X" / "2×" (× 是 U+00D7)
    //    使用负向后行断言排除 "-1x" 中的 "1x" 匹配。
    final xSuffix = RegExp(r'(?<![-\d.])([0-9]+(?:\.[0-9]+)?)\s*[xX×]');
    final m2 = xSuffix.firstMatch(trimmed);
    if (m2 != null) {
      final v = double.tryParse(m2.group(1)!);
      if (_isValidMultiplier(v)) return v;
    }

    // 3) "2倍" / "2 倍"（中文倍）
    final beiSuffix = RegExp(r'(?<![-\d.])([0-9]+(?:\.[0-9]+)?)\s*倍');
    final m3 = beiSuffix.firstMatch(trimmed);
    if (m3 != null) {
      final v = double.tryParse(m3.group(1)!);
      if (_isValidMultiplier(v)) return v;
    }

    // 4) "x2" / "X2" / "×2" 前缀形式（较少见，但兼容）
    final xPrefix = RegExp(r'[xX×]\s*([0-9]+(?:\.[0-9]+)?)');
    final m4 = xPrefix.firstMatch(trimmed);
    if (m4 != null) {
      final v = double.tryParse(m4.group(1)!);
      if (_isValidMultiplier(v)) return v;
    }

    return null;
  }

  /// 解析倍率，未识别时返回默认值 1.0。
  static double parseOrDefault(String nodeName, {double defaultValue = 1.0}) {
    return parse(nodeName) ?? defaultValue;
  }

  static bool _isValidMultiplier(double? v) {
    if (v == null) return false;
    if (v.isNaN || v.isInfinite) return false;
    // 倍率合理范围：0 < v <= 100，避免解析错误产生离谱值。
    return v > 0 && v <= 100;
  }

  /// 比较两个倍率是否在显示精度内相等（避免浮点误差）。
  static bool approxEquals(double a, double b, {double epsilon = 1e-9}) {
    return (a - b).abs() < epsilon || (a - b).abs() < epsilon * max(a.abs(), b.abs());
  }
}
