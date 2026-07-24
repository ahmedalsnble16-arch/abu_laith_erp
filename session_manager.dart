// lib/core/auth/session_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';
import 'dart:convert';

class SessionManager {
  static SessionManager? _instance;
  static SharedPreferences? _prefs;

  static const String _keyUser = 'current_user';
  static const String _keyToken = 'auth_token';
  static const String _keyIsLoggedIn = 'is_logged_in';

  SessionManager._internal();

  factory SessionManager() {
    _instance ??= SessionManager._internal();
    return _instance!;
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // حفظ بيانات المستخدم بعد تسجيل الدخول
  Future<void> saveUser(User user) async {
    await _prefs?.setString(_keyUser, jsonEncode(user.toMap()));
    await _prefs?.setBool(_keyIsLoggedIn, true);
  }

  // الحصول على المستخدم الحالي
  User? getCurrentUser() {
    final userData = _prefs?.getString(_keyUser);
    if (userData == null) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(userData);
      return User.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  // التحقق من تسجيل الدخول
  bool isLoggedIn() {
    return _prefs?.getBool(_keyIsLoggedIn) ?? false;
  }

  // الحصول على رمز المصادقة
  String? getToken() {
    return _prefs?.getString(_keyToken);
  }

  // حفظ رمز المصادقة
  Future<void> saveToken(String token) async {
    await _prefs?.setString(_keyToken, token);
  }

  // الحصول على معرف المستخدم الحالي
  String? getCurrentUserId() {
    return getCurrentUser()?.id;
  }

  // الحصول على دور المستخدم الحالي
  String? getCurrentUserRole() {
    return getCurrentUser()?.roleId;
  }

  // التحقق من صلاحية المستخدم
  bool hasRole(String roleId) {
    return getCurrentUser()?.roleId == roleId;
  }

  // هل المستخدم مدير عام
  bool isAdmin() {
    return getCurrentUser()?.roleId == 'role_admin';
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await _prefs?.remove(_keyUser);
    await _prefs?.remove(_keyToken);
    await _prefs?.setBool(_keyIsLoggedIn, false);
  }
}