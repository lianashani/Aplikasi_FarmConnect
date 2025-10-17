import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/sensor_reading.dart';
import '../models/transaction.dart';
import '../config/api_config.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      HttpHeaders.acceptHeader: 'application/json',
    },
  ));

  ApiService() {
    // Add interceptor once
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');
          await prefs.remove('role');
          await prefs.remove('user_id');
          await prefs.remove('user_name');
        }
        return handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      final data = res.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final userJson = (data['user'] as Map<String, dynamic>?);
      final user = userJson != null ? UserModel.fromJson(userJson) : UserModel.fromJson(data);
      final role = (data['role'] ?? userJson?['role'])?.toString();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      }
      return {'token': token, 'user': user, if (role != null) 'role': role};
    } on DioException catch (e) {
      throw Exception('Login gagal: ${e.response?.data ?? e.message}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final res = await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      final data = res.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      final userJson = (data['user'] as Map<String, dynamic>?);
      final user = userJson != null ? UserModel.fromJson(userJson) : UserModel.fromJson(data);
      final roleResp = (data['role'] ?? userJson?['role'])?.toString();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      }
      return {'token': token, 'user': user, if (roleResp != null) 'role': roleResp};
    } on DioException catch (e) {
      throw Exception('Register gagal: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('role');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
    }
  }

  Future<UserModel> me() async {
    try {
      final res = await _dio.get('/user/profile');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Gagal memuat profil: ${e.response?.data ?? e.message}');
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final res = await _dio.get('/products');
      final body = res.data;
      final List items = (body is Map<String, dynamic>) ? (body['data'] ?? []) : body;
      return items.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Gagal memuat produk: ${e.response?.data ?? e.message}');
    }
  }

  Future<Product> createProduct({
    required String name,
    String? description,
    required double price,
    required String unit,
    required int stock,
    String? imageUrl,
    String? imagePath,
  }) async {
    try {
      Response res;
      if (imagePath != null && imagePath.isNotEmpty) {
        final form = FormData.fromMap({
          'name': name,
          'description': description,
          'price': price,
          'unit': unit,
          'stock': stock,
          if (imageUrl != null) 'image_url': imageUrl,
          'image': await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
        });
        res = await _dio.post('/products', data: form);
      } else {
        res = await _dio.post('/products', data: {
          'name': name,
          'description': description,
          'price': price,
          'unit': unit,
          'stock': stock,
          'image_url': imageUrl,
        });
      }
      return Product.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Gagal membuat produk: ${e.response?.data ?? e.message}');
    }
  }

  Future<Product> updateProduct({
    required int id,
    required String name,
    String? description,
    required double price,
    required String unit,
    required int stock,
    String? imageUrl,
    String? imagePath,
  }) async {
    try {
      Response res;
      if (imagePath != null && imagePath.isNotEmpty) {
        final form = FormData.fromMap({
          'name': name,
          'description': description,
          'price': price,
          'unit': unit,
          'stock': stock,
          if (imageUrl != null) 'image_url': imageUrl,
          'image': await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
        });
        res = await _dio.put('/products/$id', data: form);
      } else {
        res = await _dio.put('/products/$id', data: {
          'name': name,
          'description': description,
          'price': price,
          'unit': unit,
          'stock': stock,
          'image_url': imageUrl,
        });
      }
      return Product.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Gagal mengubah produk: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('/products/$id');
    } on DioException catch (e) {
      throw Exception('Gagal menghapus produk: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> createTransaction({required int productId, int quantity = 1}) async {
    try {
      await _dio.post('/transactions', data: {
        'product_id': productId,
        'quantity': quantity,
      });
    } on DioException catch (e) {
      throw Exception('Transaksi gagal: ${e.response?.data ?? e.message}');
    }
  }

  Future<List<AppTransaction>> getTransactions() async {
    try {
      final res = await _dio.get('/transactions');
      final body = res.data;
      final List items = (body is Map<String, dynamic>) ? (body['data'] ?? []) : body;
      return items.map((e) => AppTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Gagal memuat transaksi: ${e.response?.data ?? e.message}');
    }
  }

  Future<List<SensorReading>> getIotData() async {
    try {
      final res = await _dio.get('/iot');
      final body = res.data;
      final List items = (body is Map<String, dynamic>) ? (body['data'] ?? []) : body;
      return items.map((e) => SensorReading.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Gagal memuat data IoT: ${e.response?.data ?? e.message}');
    }
  }
}
