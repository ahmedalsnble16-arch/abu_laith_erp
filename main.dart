import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'apps/production_app.dart';
import 'apps/warehouse_app.dart';
import 'apps/showroom_app.dart';
import 'apps/treasury_app.dart';
import 'apps/distributor_app.dart';
import 'core/database/database_helper.dart';
import 'core/auth/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await DatabaseHelper().database;
  await SessionManager().init();

  // تحديد التطبيق المناسب حسب دور المستخدم
  final session = SessionManager();
  final user = session.getCurrentUser();

  Widget app;
  if (user == null) {
    // لا يوجد مستخدم مسجل -> تطبيق المدير العام
    app = const AbuLaithERPApp();
  } else {
    switch (user.roleId) {
      case 'role_production':
        app = const ProductionApp();
        break;
      case 'role_warehouse':
        app = const WarehouseApp();
        break;
      case 'role_showroom':
        app = const ShowroomApp();
        break;
      case 'role_accountant':
        app = const TreasuryApp();
        break;
      case 'role_distributor':
        app = const DistributorApp();
        break;
      default:
        // المدير العام أو أي دور آخر غير معروف
        app = const AbuLaithERPApp();
    }
  }

  runApp(app);
}