import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final _api = ApiService();

  String? _token;
  int? _userId;
  String? _name;
  String _role = 'buyer'; // default if backend doesn't send

  String? get token => _token;
  int? get userId => _userId;
  String? get name => _name;
  String get role => _role;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> tryRestore() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getInt('user_id');
    _name = prefs.getString('user_name');
    _role = prefs.getString('role') ?? 'buyer';
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final res = await _api.login(email, password);
    final token = res['token'] as String?;
    final user = res['user'];
    final prefs = await SharedPreferences.getInstance();
    if (token != null) await prefs.setString('token', token);
    final uid = (user.id as int?);
    if (uid != null) await prefs.setInt('user_id', uid);
    await prefs.setString('user_name', user.name as String);
    // role: prefer API field, then user.role, else buyer
    final role = (res['role'] as String?) ?? (user.role as String?) ?? 'buyer';
    await prefs.setString('role', role);

    _token = token;
    _userId = uid;
    _name = user.name as String;
    _role = role;
    notifyListeners();
  }

  Future<void> register({required String name, required String email, required String password}) async {
    final res = await _api.register(name: name, email: email, password: password);
    final token = res['token'] as String?;
    final user = res['user'];
    final prefs = await SharedPreferences.getInstance();
    if (token != null) await prefs.setString('token', token);
    final uid = (user.id as int?);
    if (uid != null) await prefs.setInt('user_id', uid);
    await prefs.setString('user_name', user.name as String);
    final role = (res['role'] as String?) ?? (user.role as String?) ?? 'buyer';
    await prefs.setString('role', role);

    _token = token;
    _userId = uid;
    _name = user.name as String;
    _role = role;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('role');
    _token = null;
    _userId = null;
    _name = null;
    _role = 'buyer';
    notifyListeners();
  }
}
