/// 非整数倍率精度工具。
///
/// 问题：若每次小增量直接用 `double` 计算 `(bytes * multiplier).floor()`，
/// 长期累积会系统性低估（例如 0.1× 反复截断）。本工具采用"毫字节余数"
/// 方案，全程整数运算，避免浮点误差累积。
///
/// 约定：
/// - 倍率转为毫倍率 `multiplierMillis = (multiplier * 1000).round()`；
/// - 增量毫扣量 `billedMillis = deltaBytes * multiplierMillis`（整数乘法）；
/// - 整数部分 `estimatedDelta = billedMillis ~/ 1000`；
/// - 余数部分 `remainderDelta = billedMillis % 1000`；
/// - 累加时：`totalRemainder = existingRemainder + remainderDelta`，
///   进位 `carry = totalRemainder ~/ 1000`，
///   `newEstimated = existingEstimated + estimatedDelta + carry`，
///   `newRemainder = totalRemainder % 1000`。
///
/// 这样多次小增量累计后，预计扣量严格等于 `sum(bytes) * multiplier`
/// 在毫精度下的取整，不会因反复截断明显低估。
class MultiplierPrecision {
  const MultiplierPrecision._();

  /// 将 double 倍率转为毫倍率（整数）。仅在此转换点产生一次取整误差。
  static int toMillis(double multiplier) {
    return (multiplier * 1000).round();
  }

  /// 计算单次增量的毫扣量（整数乘法，无浮点累积）。
  static int billedMillis(int deltaBytes, int multiplierMillis) {
    return deltaBytes * multiplierMillis;
  }

  /// 从毫扣量拆出整数字节部分和余数（milliBytes）。
  static ({int estimated, int remainder}) split(int billedMillis) {
    return (
      estimated: billedMillis ~/ 1000,
      remainder: billedMillis % 1000,
    );
  }

  /// 累加一次增量到已有 estimated/remainder 上。
  ///
  /// [existingEstimated] 已入账的整数字节。
  /// [existingRemainder] 已累积的毫字节余数（0–999）。
  /// [deltaBytes] 本次实际增量字节。
  /// [multiplierMillis] 本次有效倍率的毫倍率。
  ///
  /// 返回累加后的 (estimated, remainder)。
  static ({int estimated, int remainder}) accumulate({
    required int existingEstimated,
    required int existingRemainder,
    required int deltaBytes,
    required int multiplierMillis,
  }) {
    if (deltaBytes < 0) {
      throw ArgumentError.value(
        deltaBytes,
        'deltaBytes',
        'delta must be non-negative',
      );
    }
    final billed = deltaBytes * multiplierMillis;
    final totalRemainder = existingRemainder + (billed % 1000);
    final carry = totalRemainder ~/ 1000;
    return (
      estimated: existingEstimated + (billed ~/ 1000) + carry,
      remainder: totalRemainder % 1000,
    );
  }

  /// 校验余数始终在 [0, 999]。
  static bool isValidRemainder(int remainder) =>
      remainder >= 0 && remainder < 1000;

  /// 比较 two multiplier 在毫精度下是否等价。
  static bool multiplierEquals(double a, double b) =>
      toMillis(a) == toMillis(b);
}

/// 未估算扣量的哨兵值。
///
/// 当节点无法可靠识别（未归因代理流量、未知节点）时，预计扣量不能伪造为
/// 1×。用此哨兵标识"该部分无法可靠估算机场扣量"，UI 可据此显示
/// "已估算覆盖率 / 未估算实际流量"。
///
/// 存储约定：billedRemainder 列使用 [-1] 表示不可估算；
/// estimatedBilledBytes 列此时保持 [0]（实际流量仍计入 bytesUp/Down）。
const int unbilledSentinel = -1;

/// 判断给定余数是否为不可估算哨兵。
bool isUnbilled(int remainder) => remainder == unbilledSentinel;
