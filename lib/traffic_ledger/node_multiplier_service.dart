import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/traffic_ledger/multiplier_parser.dart';

/// 节点倍率服务。负责：
/// - 从节点名自动解析倍率并持久化 [parsedMultiplier]；
/// - 接受用户手动覆盖 [manualMultiplier]；
/// - 提供 effective 倍率查询（manual ?? parsed）；
/// - 关键：修改倍率只影响后续新写入的流量，历史流量表的 multiplier 是
///   入账时快照，不会被这里的方法回写。
class NodeMultiplierService {
  NodeMultiplierService(this._dao);

  final TrafficLedgerDao _dao;

  /// 为节点名刷新自动解析的倍率。若用户已有手动覆盖，则保留手动覆盖，
  /// 仅更新 parsedMultiplier。返回当前 effective 倍率。
  Future<double> refreshParsedMultiplier(
    String nodeName, {
    DateTime? now,
  }) async {
    final parsed = MultiplierParser.parseOrDefault(nodeName);
    final existing = await _dao.getNodeMultiplier(nodeName);
    await _dao.upsertNodeMultiplier(
      nodeName: nodeName,
      parsedMultiplier: parsed,
      manualMultiplier: existing?.manualMultiplier,
      now: now,
    );
    return existing?.manualMultiplier ?? parsed;
  }

  /// 设置用户手动覆盖。传 null 清除手动覆盖（恢复自动解析值）。
  Future<void> setManualMultiplier(
    String nodeName,
    double? manualMultiplier, {
    DateTime? now,
  }) async {
    final existing = await _dao.getNodeMultiplier(nodeName);
    if (existing == null) {
      // 节点尚无记录，先按解析值建一条再覆盖。
      final parsed = MultiplierParser.parseOrDefault(nodeName);
      await _dao.upsertNodeMultiplier(
        nodeName: nodeName,
        parsedMultiplier: parsed,
        manualMultiplier: manualMultiplier,
        now: now,
      );
      return;
    }
    await _dao.setManualMultiplier(
      nodeName: nodeName,
      manualMultiplier: manualMultiplier,
      now: now,
    );
  }

  /// 获取节点 effective 倍率。若节点无记录，返回解析值（默认 1.0），
  /// 不自动写库（避免查询产生副作用）。
  Future<double> getEffectiveMultiplier(String nodeName) async {
    final existing = await _dao.getNodeMultiplier(nodeName);
    if (existing != null) {
      return existing.manualMultiplier ?? existing.parsedMultiplier;
    }
    return MultiplierParser.parseOrDefault(nodeName);
  }

  /// 获取节点倍率记录（含 parsed/manual）。若无则返回 null。
  Future<TrafficNodeMultiplier?> getRecord(String nodeName) {
    return _dao.getNodeMultiplier(nodeName);
  }
}
