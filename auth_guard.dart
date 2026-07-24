import 'package:flutter/material.dart';
import 'session_manager.dart';
import '../../ui/auth/login_screen.dart';

class AuthGuard {
  static final Map<String, List<String>> rolePermissions = {
    'role_admin': [
      '/', '/dashboard', '/products', '/raw-materials', '/production',
      '/warehouse', '/showroom', '/treasury', '/expenses',
      '/distributors', '/reports', '/sync', '/settings', '/users',
    ],
    'role_production': [
      '/', '/dashboard', '/production', '/raw-materials', '/reports',
    ],
    'role_warehouse': [
      '/', '/dashboard', '/warehouse', '/raw-materials', '/stock',
    ],
    'role_accountant': [
      '/', '/dashboard', '/treasury', '/expenses', '/reports', '/customers', '/suppliers',
    ],
    'role_showroom': [
      '/', '/dashboard', '/showroom', '/sales',
    ],
    'role_distributor': [
      '/', '/dashboard', '/distributors',
    ],
    'role_materials': [
      '/', '/dashboard', '/raw-materials', '/purchases', '/suppliers',
    ],
  };

  static bool canAccess(String? roleId, String route) {
    if (roleId == null) return false;
    final allowedRoutes = rolePermissions[roleId] ?? [];
    return allowedRoutes.contains(route);
  }

  static Widget guard(BuildContext context, Widget child) {
    final session = SessionManager();
    if (!session.isLoggedIn()) {
      return const LoginScreen();
    }

    final user = session.getCurrentUser();
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    if (!canAccess(user?.roleId, currentRoute)) {
      return Scaffold(
        appBar: AppBar(title: const Text('غير مصرح')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('ليس لديك صلاحية للوصول إلى هذه الصفحة'),
            ],
          ),
        ),
      );
    }

    return child;
  }
}