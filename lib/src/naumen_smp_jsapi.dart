@JS()
library jsApi;

import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:js';

import "package:js/js.dart";
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

@JS('top')
abstract class Top {
  @JS('top.injectJsApi')
  external static void injectJsApi(dynamic top, dynamic window);
}

@JS("Promise")
class Promise {
  external void then(Function onFulfilled, Function onRejected);

  external static Promise resolve(dynamic value);
}

@JS('jsApi')
abstract class JsApi {
  @JS('jsApi.findContentCode')
  external static String findContentCode();

  @JS('jsApi.extractSubjectUuid')
  external static String extractSubjectUuid();

  @JS('jsApi.registerAttributeToModification')
  external static void registerAttributeToModification(
      String attrCode, Function resultCallBack);

  @JS('jsApi.isAddForm')
  external static bool isAddForm();

  @JS('jsApi.isEditForm')
  external static bool isEditForm();

  @JS('jsApi.isOnObjectCard')
  external static bool isOnObjectCard();

  @JS('jsApi.getCurrentUser')
  external static dynamic getCurrentUser();

  @JS('jsApi.getAppBaseUrl')
  external static String getAppBaseUrl();

  @JS('jsApi.getAppRestBaseUrl')
  external static String getAppRestBaseUrl();

  @JS('jsApi.restCall')
  external static Promise restCall(String restOfTheUrl, Map options);

  @JS('jsApi.restCallAsJson')
  external static Promise restCallAsJson(String restOfTheUrl, Map options);

  @JS('jsApi.addFieldChangeListener')
  external static void addFieldChangeListener(
      String attrCode, void Function(Attribute) callback);

  external static Commands get commands;
}

@JS('jsApi.commands')
abstract class Commands {
  @JS('jsApi.commands.getCurrentContextObject')
  external static Promise getCurrentContextObject();

  @JS('jsApi.commands.selectObjectDialog')
  external static Promise selectObjectDialog(
      String classFqn, String presentAttributesGroupCode);

  @JS('jsApi.commands.changeState')
  external static void changeState(String uuid, List<String> states);

  @JS('jsApi.commands.editObject')
  external static Promise editObject(String uuid);
}

@JS('jsApi.requests')
abstract class Requests {
  @JS('jsApi.requests.make')
  external static Promise make(Map options);

  @JS('jsApi.requests.json')
  external static Promise json(Map options);
}

@JS('jsApi.urls')
abstract class Urls {
  @JS('jsApi.urls.base')
  external static String base();

  @JS('jsApi.urls.objectCard')
  external static String objectCard(String uuid);

  @JS('jsApi.urls.objectEditForm')
  external static String objectEditForm(String uuid);

  @JS('jsApi.urls.objectAddForm')
  external static String objectAddForm(String fqn);
}

@JS('jsApi.configuration')
abstract class Configuration {
  @JS('jsApi.configuration.byContentCode')
  external static Promise byContentCode(String moduleCode, List args);

  @JS('jsApi.configuration.byDefault')
  external static Promise byDefault(String moduleCode, List args);
}

@JS()
@anonymous
abstract class Attribute {
  String get attribute;

  dynamic get newValue;
}

class SmpAPI {
  /// Таймаут на поиск родительского окна
  static final int _timeOut = 1000;

  /// Заголовки для REST API запросов в сторону сервера Naumen SMP
  static final _headers = {'Content-Type': 'application/json'};

  /// Адрес REST API сервиса Naumen SMP для поиска объектов
  static String _find = '../services/rest/find';

  /// Адрес REST API сервиса Naumen SMP для получения объекта по UUID
  static String _get = '../services/rest/get';

  /// Адрес REST API сервиса Naumen SMP для редактирования объекта
  static String _edit = '../services/rest/edit';

  /// Адрес REST API сервиса Naumen SMP для создания объекта M2M
  static String _create = '../services/rest/create-m2m';

  /// Адрес REST API сервиса Naumen SMP для исполнения скриптовых модулей или удаленного выполнения скриптов
  static String _execPost = '../services/rest/exec-post';

  static BrowserClient _http = new BrowserClient();
  static JsonCodec json = const JsonCodec();

  static String get apiType => 'Dart Naumen SMP API';

  /// Метод REST API сервиса Naumen SMP для поиска, возвращает первый найденный
  static Future<Map> findFirst(String url) async {
    try {
      List data = await find(url);
      return data.length > 0 ? data.first : {};
    } catch (e) {
      print(e.toString());
      return {};
    }
  }

  /// Метод REST API сервиса Naumen SMP для получения объекта по URL
  static Future<Map> getObjectByUrl(String url) async {
    try {
      final response = await _http.get(url);
      return _extractData(response);
    } catch (e) {
      return {};
    }
  }

  /// Метод REST API сервиса Naumen SMP для получения объекта по UUID
  static Future<Map> get(String url) async {
    try {
      final response = await _http.get('$_get/$url');
      return _extractData(response);
    } catch (e) {
      return {};
    }
  }

  /// Метод REST API сервиса Naumen SMP для поиска объектов
  static Future<List> find(String url) async {
    try {
      final response = await _http.get('$_find$url');
      return _extractData(response);
    } catch (e) {
      return [];
    }
  }

  /// Метод REST API сервиса Naumen SMP для создания объекта
  static Future<Map> create(String url, Map data) async {
    try {
      final response = await _http.post('$_create$url',
          headers: _headers, body: json.encode(data));
      return _extractData(response);
    } catch (e) {
      print(e.toString());
      return {};
    }
  }

  /// Метод REST API сервиса Naumen SMP для исполнения скриптового модуля с передачей requestContent
  static Future<Map> execPost(String url, Map data) async {
    try {
      final response = await _http.post('$_execPost$url',
          headers: _headers, body: json.encode(data));
      return _extractData(response);
    } catch (e) {
      print(e.toString());
      return {};
    }
  }

  /// Метод REST API сервиса Naumen SMP для редактирования объекта
  static Future<String> edit(String url, Map data) async {
    String body = json.encode(data);
    try {
      final response =
          await _http.post('$_edit$url', headers: _headers, body: body);
      return response.body;
    } catch (e) {
      print(e.toString());
      return 'Rest error';
    }
  }

  /// Метод REST API сервиса Naumen SMP для получения объекта по URL
  static _extractData(Response resp) => json.decode(resp.body);

  /// Проверяет, встроено ли приложение как IFRAME
  static bool get isEmbedded => context['frameElement'] != null;

  /// Если встроено как IFRAME, то возвращает TOP
  static get top => isEmbedded ? context['top'] : null;

  /// Возвращает контекст текущего окна
  static get cWindow => JsObject.fromBrowserObject(context['window']);

  /// Возвращает контекст родительского окна от iframeResizer
  static JsObject get parentIFrame {
    var parentIFrame = cWindow['parentIFrame'];
    int timeOut = 0;
    while (parentIFrame == null && timeOut < _timeOut) {
      Future.delayed(Duration(milliseconds: timeOut), () {
        timeOut += 50;
        parentIFrame = cWindow['parentIFrame'];
      });
    }
    if (timeOut > _timeOut) {
      throw ('iframe has no `parentIFrame` property. ' +
          'Did you include iframeResizer.contentWindow.js before any other scripts?');
    }
    return JsObject.fromBrowserObject(parentIFrame);
  }

  /// Возвращает контекст JS API, при необходимости инициализирует его
  static JsObject get jsApi {
    JsObject _jsApi = context['jsApi'];
    if (_jsApi == null && top != null) {
      top.callMethod('injectJsApi', [top, cWindow]);
      _jsApi = context['jsApi'];
    }
    return _jsApi;
  }

  /// Исполняет метод из контекста JS API
  static dynamic execContextFunction(String function,
      [List params = const []]) {
    JsObject _jsApi = jsApi;
    if (_jsApi == null) {
      print('Не удалось инициализировать jsApi');
      return null;
    }
    return jsApi.callMethod(function, params);
  }

  /// Получает параметр из контекста JS API
  static String getContextParam(String function, [List params = const []]) {
    return execContextFunction(function, params) as String;
  }

  /// Возвращает код контента, в которое встроено приложение
  static String get contentCode => getContextParam('findContentCode');

  /// Возвращает код контента, в которое встроено приложение (по аналогии с JS API)
  static String findContentCode() => contentCode;

  /// Возвращает UUID карточки, на которую встроено приложение
  static String get currentUUID => getContextParam('extractSubjectUuid');

  /// Возвращает код контента, в которое встроено приложение (по аналогии с JS API)
  static String extractSubjectUuid() => currentUUID;

  /// Приложение встроено на форму добавления
  static bool get isAddForm => execContextFunction('isAddForm') as bool;

  /// Приложение встроено на форму редактирования
  static bool get isEditForm => execContextFunction('isEditForm') as bool;

  /// Приложение встроено на карточку
  static bool get isOnObjectCard =>
      execContextFunction('isOnObjectCard') as bool;

  /// Получить ссылку на карточку объекта по UUID
  static String objectCard(String uuid) =>
      execContextFunction('objectCard', [uuid]);

  /// Получить ссылку на форму редактирования объекта по UUID
  static String objectEditForm(String uuid) =>
      execContextFunction('objectEditForm', [uuid]);

  /// Получить ссылку на форму добавления объекта по FQN
  static String objectAddForm(String fqn) =>
      execContextFunction('objectAddForm', [fqn]);

  /// Установить значение HASH головного окна
  static void setCurrentHash(String hash) {
    context['top']['location']['hash'] = hash;
  }

  /// Зарегистрировать изменение (заполнение атрибута) во время добавления объекта
  static void registerAttributeToModification(
          String attrCode, Function callback) =>
      execContextFunction(
          'registerAttributeToModification', [attrCode, callback]);

  /// Зарегистрировать функцию на отслеживание изменений по атрибуту
  static void addFieldChangeListener(String attrCode, Function callback) =>
      execContextFunction('addFieldChangeListener', [attrCode, callback]);

  /// Команды
  ///
  /// Перечень методов, для вызова команд текущего контекста

  /// Отправить сообщение через iframeResizer
  static void sendMessage(var message) {
    if (message is Map) {
      message = jsonEncode(message);
    }
    parentIFrame.callMethod('sendMessage', [message]);
  }

  /// Ожидать исполнения команды
  static Future<Map> waitForCommandResponse(String commandName,
      [Map commandArguments = const {}]) async {
    Map resolve;
    Map command = {commandName: commandArguments};
    sendMessage(jsonEncode(command));
    await window.onMessage.firstWhere((MessageEvent event) {
      if (event.data == commandName + '.cancelled') {
        return true;
      }
      try {
        resolve = jsonDecode(event.data);
      } catch (e) {
        print('Ошибка обработки postMessage: ${e.toString()}');
      }
      if (resolve is Map && resolve['command'] == commandName) {
        return true;
      }
    });
    return resolve;
  }

  /// Команда для получения объекта из текущего GWT контекста
  ///
  /// Для страниц добавления/редактирования - это текущий добавляемый и
  /// редактируемый объект, для карточки объекта - текущий объект
  static Future<Map> getCurrentContextObject() async {
    return await waitForCommandResponse('getCurrentContextObject');
  }

  /// Команда для смены статуса объекта.
  ///
  /// Если статусов больше 1, либо при входе в статус есть обязательные
  /// для заполнения атрибуты, появляется форма смены статуса.
  static void changeState(String uuid, List<String> states) => sendMessage({
        'changeState': {'uuid': uuid, 'statuses': states}
      });

  /// Команда для перехода на форму редактирования объекта
  static void editObject(String uuid) => sendMessage({
        'editObject': {'uuid': uuid}
      });

  /// Команда для открытия сложной формы добавления связи и выбора объекта
  static Future<String> selectObjectDialog(
      String classFqn, String presentAttributesGroupCode) {
    return waitForCommandResponse('selectObjectDialog', {
      'classFqn': classFqn,
      'presentAttributesGroupCode': presentAttributesGroupCode
    }).then((Map response) {
      if (response == null || !response.containsKey('uuid')) {
        throw ('"uuid" property is absent. Got: ${response.toString()}');
      }
      return response['uuid'];
    });
  }
}
