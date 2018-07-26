# naumen_smp_jsapi

Библиотека для разработки встраиваемых приложений Naumen SMP на Dart.


## Использование

Простой пример использования:

    import 'package:naumen_smp_jsapi/naumen_smp_jsapi.dart';

         main() {
           print('Приложение встроено на карточку с UUID: ${SmpAPI.currentUUID}');
           print('Код контента приложения: ${SmpAPI.contentCode}');
         }

## Замечания и предложения

Вы можете оставлять свои замечания и предложения в [трекер][tracker] этого репозитория.

[tracker]: https://github.com/mdemyanov/naumen-smp-jsapi/issues
