/// 域名规范化器（Stage 3.1）。
///
/// 当前实现为**保守方案**：仅做规范化（小写、去末尾点），不进行
/// eTLD+1 归并。理由：
///
/// - 项目当前无 PSL（Public Suffix List）依赖；
/// - 手写不完整的公共后缀规则会制造错误归并（用户明确禁止）；
/// - 引入新依赖需评估维护状态，不在本阶段范围。
///
/// 后续若引入维护正常的 PSL 解析依赖（如 `public_suffix`），可替换
/// [normalize] 实现，在不影响调用方的前提下升级为 eTLD+1 归并。
///
/// 当前策略保证：
/// - `API.GitHub.com.` → `api.github.com`（规范化）
/// - `api.github.com` 与 `github.com` 是**两个不同**的聚合键（不归并）
/// - IPv4 / IPv6 字面量保留不变
/// - 空 host → ''（由调用方回退到 destinationIP）
class DomainNormalizer {
  const DomainNormalizer._();

  /// 规范化域名。
  ///
  /// 步骤：
  /// 1. trim + 去末尾点（`api.example.com.` → `api.example.com`）；
  /// 2. 全小写（DNS 不区分大小写）；
  /// 3. IP 字面量保留不变（IPv4 / IPv6）；
  /// 4. 空字符串返回空。
  ///
  /// **不**进行 eTLD+1 归并。`api.github.com` 和 `github.com` 是两个 key。
  static String normalize(String host) {
    final trimmed = host.trim();
    if (trimmed.isEmpty) return '';

    // 去末尾点（DNS 根标签标记）。
    var result = trimmed;
    while (result.length > 1 && result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }

    // IP 字面量：IPv4 或 IPv6（含冒号或全数字点分）。
    if (_isIpLiteral(result)) {
      return result; // 不小写化 IPv6 中的 hex（其实也可以小写，但保持原样）
    }

    // DNS 域名不区分大小写。
    return result.toLowerCase();
  }

  /// 判断字符串是否为 IP 字面量。
  ///
  /// - IPv4: 四段点分数字，每段 0–255；
  /// - IPv6: 含冒号（简化判断，完整验证需 inet_pton）。
  static bool _isIpLiteral(String s) {
    if (s.isEmpty) return false;
    // IPv6 简化判断：含冒号即认为是 IPv6 字面量。
    if (s.contains(':')) return true;
    // IPv4：四段数字点分。
    final parts = s.split('.');
    if (parts.length != 4) return false;
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }
}
