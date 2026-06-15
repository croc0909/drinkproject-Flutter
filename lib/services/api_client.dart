import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/drink.dart';
import '../models/order.dart';
import '../models/auth.dart';

// API 發生錯誤時使用的例外類別。
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

// ApiClient 專門負責和 Go 後端溝通。
// ViewModel 不直接寫 HTTP 細節，而是呼叫這裡的方法。
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    // 預設後端 API 位置。
    // 如果用 Android Emulator 連本機後端，通常要改成 http://10.0.2.2:8080/api。
    this.baseUrl = 'http://localhost:8080/api',
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final String baseUrl;

  // GET /api/drinks
  // 從後端取得飲品列表。
  Future<List<Drink>> fetchDrinks() async {
    final uri = Uri.parse('$baseUrl/drinks');
    _log('GET $uri -> start');

    final response = await _httpClient.get(uri);
    _log(
      'GET $uri <- status ${response.statusCode}, body: ${_preview(response.body)}',
    );

    // 確認 HTTP 狀態碼是 2xx。
    _validate(response, endpoint: 'GET /api/drinks');

    // 將 response.body 的 JSON 字串轉成 Dart List，再轉成 List<Drink>。
    final decoded = jsonDecode(response.body) as List<dynamic>;
    final drinks = decoded
        .map((item) => Drink.fromJson(item as Map<String, dynamic>))
        .toList();
    _log('GET $uri <- decoded ${drinks.length} drinks');
    return drinks;
  }

  // POST /api/orders
  // 將購物車內容送到後端建立訂單。
  Future<Order> submitOrder(
    CreateOrderRequest orderRequest, {
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/orders');
    final requestBody = jsonEncode(orderRequest.toJson());
    _log('POST $uri -> body: ${_preview(requestBody)}');

    final response = await _httpClient.post(
      uri,
      // 告訴後端 body 是 JSON 格式。
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: requestBody,
    );
    _log(
      'POST $uri <- status ${response.statusCode}, body: ${_preview(response.body)}',
    );

    _validate(response, endpoint: 'POST /api/orders');

    final order =
        Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    _log('POST $uri <- created order id ${order.id}');
    return order;
  }

  Future<List<Order>> fetchOrders({required String token}) async {
    final uri = Uri.parse('$baseUrl/me/orders');
    _log('GET $uri -> start');

    final response = await _httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    _log(
      'GET $uri <- status ${response.statusCode}, body: ${_preview(response.body)}',
    );

    _validate(response, endpoint: 'GET /api/me/orders');

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Order.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AuthResponse> register({
    required String phone,
    required String name,
    required String password,
  }) async {
    return _postAuth(
      path: 'auth/register',
      body: {'phone': phone, 'name': name, 'password': password},
      endpoint: 'POST /api/auth/register',
    );
  }

  Future<AuthResponse> login({
    required String phone,
    required String password,
  }) async {
    return _postAuth(
      path: 'auth/login',
      body: {'phone': phone, 'password': password},
      endpoint: 'POST /api/auth/login',
    );
  }

  Future<User> fetchMe({required String token}) async {
    final uri = Uri.parse('$baseUrl/me');
    _log('GET $uri -> start');

    final response = await _httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    _log(
      'GET $uri <- status ${response.statusCode}, body: ${_preview(response.body)}',
    );

    _validate(response, endpoint: 'GET /api/me');
    return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AuthResponse> _postAuth({
    required String path,
    required Map<String, dynamic> body,
    required String endpoint,
  }) async {
    final uri = Uri.parse('$baseUrl/$path');
    final requestBody = jsonEncode(body);
    _log('POST $uri -> body: ${_preview(requestBody)}');

    final response = await _httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );
    _log(
      'POST $uri <- status ${response.statusCode}, body: ${_preview(response.body)}',
    );

    _validate(response, endpoint: endpoint);
    return AuthResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  // 檢查後端回應是否成功。
  // 200~299 表示成功，其餘狀態碼就丟出錯誤。
  void _validate(http.Response response, {required String endpoint}) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _log('$endpoint failed with status ${response.statusCode}');
      final message = _backendErrorMessage(response.body);
      throw ApiException(message ?? '無法連線到後端服務。HTTP ${response.statusCode}');
    }
  }

  String? _backendErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final message = decoded['error'] as String?;
      if (message != null && message.isNotEmpty) return message;
    } catch (_) {
      return null;
    }
    return null;
  }

  // 統一 API log 前綴，方便在 Android Studio Console 搜尋。
  void _log(String message) {
    debugPrint('[API] $message');
  }

  // 避免 response body 太長，把 log 壓在容易閱讀的長度。
  String _preview(String body) {
    const maxLength = 300;
    if (body.length <= maxLength) return body;
    return '${body.substring(0, maxLength)}...';
  }
}
