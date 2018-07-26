import 'package:naumen_smp_jsapi/naumen_smp_jsapi.dart';

main() {
  print('Приложение встроено на карточку с UUID: ${SmpAPI.currentUUID}');
  print('Код контента приложения: ${SmpAPI.contentCode}');
}
