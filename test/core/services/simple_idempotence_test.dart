import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/services/language_toggle_counter.dart';

/// 简单的幂等性测试，验证核心功能
void main() {
  test('Simple idempotence verification', () {
    final counter = LanguageToggleCounter.instance;
    counter.reset();

    // 开始会话
    counter.startSession('zh');

    // 奇数次切换 - 应该切换到另一种语言
    counter.recordToggle('zh', 'en');
    var result = counter.verifyIdempotence();
    expect(result.isValid, isTrue);
    expect(result.toggleCount, equals(1));
    expect(result.expectedLanguage, equals('en'));

    // 偶数次切换 - 应该回到初始语言
    counter.recordToggle('en', 'zh');
    result = counter.verifyIdempotence();
    expect(result.isValid, isTrue);
    expect(result.toggleCount, equals(2));
    expect(result.expectedLanguage, equals('zh'));

    print('✓ Idempotence verification passed!');
    print('  - Odd toggles correctly switch to alternate language');
    print('  - Even toggles correctly return to initial language');

    counter.reset();
  });
}
