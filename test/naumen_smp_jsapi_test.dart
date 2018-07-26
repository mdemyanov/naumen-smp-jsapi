import 'package:naumen_smp_jsapi/naumen_smp_jsapi.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    test('First Test', () {
      expect(SmpAPI.apiType == 'Dart Naumen SMP API', isTrue);
    });
  });
}
