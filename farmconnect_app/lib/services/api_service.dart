import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/sensor_reading.dart';
import '../models/transaction.dart';
import '../config/api_config.dart';

class ApiService {
  // Ganti ke 10.0.2.2 jika pakai Android emulator
  static const String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      final user = UserModel.fromJson(data);
      final role = (data['role'] ?? (data['user'] is Map<String, dynamic> ? (data['user']['role']) : null))?.toString();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      }
      return {'token': token, 'user': user, if (role != null) 'role': role};
    }
    throw Exception('Login gagal: ${res.body}');
  }

  Future<Product> createProduct({
    required String name,
    String? description,
    required double price,
    required int stock,
  }) async {
    final uri = Uri.parse('$baseUrl/products');
    final token = await _getToken(optional: true);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
      }),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final Map<String, dynamic> data =
          body is Map<String, dynamic> && body['data'] is Map<String, dynamic>
              ? body['data'] as Map<String, dynamic>
              : (body as Map<String, dynamic>);
      return Product.fromJson(data);
    }
    throw Exception('Gagal membuat produk (${res.statusCode}): ${res.body}');
  }

  Future<Product> updateProduct({
    required int id,
    required String name,
    String? description,
    required double price,
    required int stock,
  }) async {
    final uri = Uri.parse('$baseUrl/products/$id');
    final token = await _getToken(optional: true);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
      }),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final Map<String, dynamic> data =
          body is Map<String, dynamic> && body['data'] is Map<String, dynamic>
              ? body['data'] as Map<String, dynamic>
              : (body as Map<String, dynamic>);
      return Product.fromJson(data);
    }
    throw Exception('Gagal mengubah produk (${res.statusCode}): ${res.body}');
  }

  Future<void> deleteProduct(int id) async {
    final uri = Uri.parse('$baseUrl/products/$id');
    final token = await _getToken(optional: true);
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.delete(uri, headers: headers);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Gagal menghapus produk (${res.statusCode}): ${res.body}');
    }
  }
  

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      final user = UserModel.fromJson(data);
      final role = (data['role'] ?? (data['user'] is Map<String, dynamic> ? (data['user']['role']) : null))?.toString();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      }
      return {'token': token, 'user': user, if (role != null) 'role': role};
    }
    throw Exception('Register gagal: ${res.body}');
  }

  Future<List<Product>> getProducts() async {
    final uri = Uri.parse('$baseUrl/products');
    final token = await _getToken(optional: true);
    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List items = (body is Map<String, dynamic>) ? (body['data'] ?? []) : body;
      return items.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Gagal memuat produk: ${res.body}');
  }

  Future<void> logout() async {
    final token = await _getToken(optional: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (token == null) return;
    final res = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Logout gagal: ${res.body}');
    }
  }

  Future<String?> _getToken({bool optional = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (!optional && (token == null || token.isEmpty)) {
      throw Exception('Belum login');
    }
    return token;
  }

  Future<List<SensorReading>> getSensorReadings() async {
    final uri = Uri.parse('$baseUrl/sensors');
    final token = await _getToken(optional: true);
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.get(uri, headers: headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List items = (body is Map<String, dynamic>) ? (body['data'] ?? []) : body;
      return items.map((e) => SensorReading.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Gagal memuat data sensor: ${res.body}');
  }

  Future<void> createTransaction({required int productId, int quantity = 1}) async {
    final uri = Uri.parse('$baseUrl/transactions');
    final token = await _getToken(optional: true);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );
    if (res.statusCode != 201) {
      throw Exception('Transaksi gagal (${res.statusCode}): ${res.body}');
    }
  }

  Future<List<AppTransaction>> getTransactions() async {
    final uri = Uri.parse('$baseUrl/transactions');
    final token = await _getToken(optional: true);
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final res = await http.get(uri, headers: headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List items = (body is Map<String, dynamic>) ? (body['data'] ?? []) : body;
      return items.map((e) => AppTransaction.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Gagal memuat transaksi (${res.statusCode}): ${res.body}');
  }
}
