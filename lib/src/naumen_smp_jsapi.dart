import 'dart:async';
import 'dart:convert';
import 'dart:js';

import 'package:http/browser_client.dart';
import 'package:http/http.dart';

class SmpAPI {
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
  static get window => context['window'];

  /// Возвращает контекст JS API, при необходимости инициализирует его
  static JsObject get jsApi {
    JsObject _jsApi = context['jsApi'];
    if (_jsApi == null && top != null) {
      top.callMethod('injectJsApi', [top, window]);
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
  static String get isAddForm => getContextParam('isAddForm');

  /// Приложение встроено на форму редактирования
  static String get isEditForm => getContextParam('isEditForm');

  /// Приложение встроено на карточку
  static String get isOnObjectCard => getContextParam('isOnObjectCard');

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
      execContextFunction('registerAttributeToModification', [callback]);

  /// Зарегистрировать функцию на отслеживание изменений по атрибуту
  static void addFieldChangeListener(String attrCode, Function callback) =>
      execContextFunction('registerAttributeToModification', [callback]);
}
