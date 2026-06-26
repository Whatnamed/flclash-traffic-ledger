/// 应用标识解析器（Stage 3.1）。
///
/// 稳定聚合键优先使用 [Metadata.processPath]，仅当 processPath 为空时
/// 退回 [Metadata.process] 名。理由：
/// - 同名进程（如 `node.exe`）可能来自不同安装路径，按 process 名聚合
///   会错误合并；
/// - processPath 是绝对路径，能唯一标识一个可执行文件位置；
/// - Windows 文件系统不区分大小写，路径分隔符 `\` / `/` 可能混用。
///
/// UI 后续显示友好名称时，可从 path 提取 basename（如 `node.exe`），
/// 但 basename 不能作为聚合键。
class AppIdentifierResolver {
  const AppIdentifierResolver._();

  /// 解析稳定的应用聚合键。
  ///
  /// - processPath 非空 → 规范化后的 path（小写、统一分隔符为 `/`）；
  /// - processPath 空、process 非空 → process.trim()（原样，不规范化大小写，
  ///   因为非 Windows 平台文件名区分大小写）；
  /// - 两者均空 → ''（未识别进程，由 Reconciler 处理）。
  ///
  /// Windows 路径标准化：
  /// - 大小写：全小写（Windows 文件系统不区分大小写）；
  /// - 分隔符：`\` 转为 `/`（统一存储）；
  /// - 末尾分隔符：去除（避免 `C:/app/` 与 `C:/app` 分叉）。
  /// 非 Windows 路径（含 `/` 但无盘符）同样统一分隔符，不影响语义。
  static String resolve({
    required String processPath,
    required String process,
  }) {
    final trimmedPath = processPath.trim();
    if (trimmedPath.isNotEmpty) {
      return _normalizePath(trimmedPath);
    }
    return process.trim();
  }

  /// 规范化路径：小写 + 反斜杠转正斜杠 + 去末尾分隔符。
  static String _normalizePath(String path) {
    var p = path.toLowerCase();
    // Windows 路径常见反斜杠，统一为正斜杠。
    p = p.replaceAll('\\', '/');
    // 去除末尾分隔符（但保留根 `/`）。
    while (p.length > 1 && p.endsWith('/')) {
      p = p.substring(0, p.length - 1);
    }
    return p;
  }

  /// 从聚合键提取用于 UI 显示的友好名称（basename）。
  ///
  /// 若聚合键是路径形式（含 `/`），取最后一段；否则原样返回。
  /// 用于 Stage 4 UI 显示，不参与聚合。
  static String displayName(String appIdentifier) {
    if (appIdentifier.isEmpty) return '';
    final lastSep = appIdentifier.lastIndexOf('/');
    if (lastSep < 0) return appIdentifier;
    return appIdentifier.substring(lastSep + 1);
  }
}
