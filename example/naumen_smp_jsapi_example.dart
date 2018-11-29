import 'package:naumen_smp_jsapi/naumen_smp_jsapi.dart';

main() {
  print('Приложение встроено на карточку с UUID: ${JsApi.extractSubjectUuid()}');
  print('Код контента приложения: ${JsApi.findContentCode()}');
}
