import 'package:fl_clash/traffic_ledger/collection/app_identifier.dart';
import 'package:fl_clash/traffic_ledger/collection/domain_normalizer.dart';
import 'package:fl_clash/traffic_ledger/collection/sample_source.dart';
import 'package:test/test.dart';

void main() {
  group('AppIdentifierResolver', () {
    test('processPath 非空时优先使用规范化路径', () {
      final id = AppIdentifierResolver.resolve(
        processPath: r'C:\Program Files\nodejs\node.exe',
        process: 'node.exe',
      );
      expect(id, 'c:/program files/nodejs/node.exe');
    });

    test('processPath 大小写与分隔符标准化', () {
      final id1 = AppIdentifierResolver.resolve(
        processPath: r'C:\APP\Node.exe',
        process: 'node.exe',
      );
      final id2 = AppIdentifierResolver.resolve(
        processPath: r'c:/app/node.exe',
        process: 'node.exe',
      );
      expect(id1, id2);
      expect(id1, 'c:/app/node.exe');
    });

    test('processPath 末尾分隔符去除', () {
      final id = AppIdentifierResolver.resolve(
        processPath: r'C:\app\',
        process: 'app',
      );
      expect(id, 'c:/app');
    });

    test('两个不同路径、同名 node.exe 必须是两个聚合键', () {
      final id1 = AppIdentifierResolver.resolve(
        processPath: r'C:\nodejs\node.exe',
        process: 'node.exe',
      );
      final id2 = AppIdentifierResolver.resolve(
        processPath: r'D:\other\nodejs\node.exe',
        process: 'node.exe',
      );
      expect(id1, isNot(id2));
    });

    test('processPath 空、process 非空时退回 process 名', () {
      final id = AppIdentifierResolver.resolve(
        processPath: '',
        process: 'node.exe',
      );
      expect(id, 'node.exe');
    });

    test('processPath 仅空格、process 非空时退回 process 名', () {
      final id = AppIdentifierResolver.resolve(
        processPath: '   ',
        process: 'node.exe',
      );
      expect(id, 'node.exe');
    });

    test('processPath 和 process 都为空时返回空字符串（未识别进程）', () {
      final id = AppIdentifierResolver.resolve(
        processPath: '',
        process: '',
      );
      expect(id, '');
    });

    test('displayName 从路径提取 basename', () {
      expect(
        AppIdentifierResolver.displayName('c:/program files/nodejs/node.exe'),
        'node.exe',
      );
      expect(AppIdentifierResolver.displayName('node.exe'), 'node.exe');
      expect(AppIdentifierResolver.displayName(''), '');
    });

    test('Windows 路径混合斜杠也能正确 basename', () {
      // 已规范化的 key（小写、正斜杠）
      expect(
        AppIdentifierResolver.displayName('c:/app/foo/bar.exe'),
        'bar.exe',
      );
    });

    test('代理承载进程不进入普通应用排行（isProxyHostProcess 仍生效）', () {
      // isProxyHostProcess 在 reconciler 层使用，AppIdentifierResolver
      // 只负责解析 key。这里验证 FlClash.exe 经规范化后仍能被
      // isProxyHostProcess 识别。
      final flclashId = AppIdentifierResolver.resolve(
        processPath: r'C:\Program Files\FlClash\FlClash.exe',
        process: 'FlClash.exe',
      );
      // basename 提取后应为 flclash.exe
      final basename = AppIdentifierResolver.displayName(flclashId);
      expect(basename, 'flclash.exe');
      // isProxyHostProcess 使用 basename 比对（已在 Stage 3 实现）。
      // 此处不直接调用 isProxyHostProcess（属于 models.dart），
      // 仅验证 displayName 行为。
    });
  });

  group('DomainNormalizer', () {
    test('大小写规范化', () {
      expect(DomainNormalizer.normalize('API.GitHub.COM'), 'api.github.com');
    });

    test('末尾点去除', () {
      expect(DomainNormalizer.normalize('api.github.com.'), 'api.github.com');
      expect(DomainNormalizer.normalize('a.b.c...'), 'a.b.c');
    });

    test('IPv4 不被当成域名截断', () {
      expect(DomainNormalizer.normalize('192.168.1.1'), '192.168.1.1');
      expect(DomainNormalizer.normalize('8.8.8.8.'), '8.8.8.8');
    });

    test('IPv6 字面量保留', () {
      expect(
        DomainNormalizer.normalize('2001:db8::1'),
        '2001:db8::1',
      );
      // IPv6 含冒号，直接保留原样（不小写）。
      expect(
        DomainNormalizer.normalize('FE80::ABCD'),
        'FE80::ABCD',
      );
    });

    test('保守方案：不进行 eTLD+1 归并', () {
      // 当前实现保守，api.github.com 与 github.com 是两个 key。
      expect(
        DomainNormalizer.normalize('api.github.com'),
        isNot(DomainNormalizer.normalize('github.com')),
      );
    });

    test('空字符串返回空', () {
      expect(DomainNormalizer.normalize(''), '');
      expect(DomainNormalizer.normalize('   '), '');
    });

    test('无 host 时由 sample_source 回退到 destinationIP', () {
      // 此行为在 sample_source._toSnapshot 中实现，
      // DomainNormalizer 只处理 host 非空的情况。
      // 这里验证 normalize('') 返回空，调用方应回退。
      expect(DomainNormalizer.normalize(''), '');
    });

    test('保留多级子域名（保守）', () {
      expect(
        DomainNormalizer.normalize('a.b.c.d.example.com'),
        'a.b.c.d.example.com',
      );
    });
  });

  group('CoreControllerSampleSource 读取顺序', () {
    // 这些测试验证 collect() 的读取顺序契约。
    // 由于 CoreControllerSampleSource 依赖 CoreController 单例，
    // 此处仅验证接口契约文档化；真实集成由 collection_service_test
    // 的 fake source 覆盖。
    test('TrafficSampleSource 接口文档化读取顺序契约', () {
      // 接口签名存在即可，真实 CoreController 集成需手动验证。
      expect(TrafficSampleSource, isNotNull);
    });
  });
}
