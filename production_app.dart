import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../core/auth/session_manager.dart';
import '../ui/auth/login_screen.dart';
import '../ui/production/production_plan_screen.dart';
import '../ui/production/production_screen.dart';
import '../ui/production/production_comparison_screen.dart';
import '../ui/production/production_list_screen.dart';
import '../ui/production/production_stats_screen.dart';

class ProductionApp extends StatelessWidget {
  const ProductionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionManager();
    final user = session.getCurrentUser();
    final isProduction = user?.roleId == 'role_production';

    if (!session.isLoggedIn() || !isProduction) {
      return const LoginScreen();
    }

    return MaterialApp(
      title: 'أبو ليث - مدير الإنتاج',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ProductionDashboard(),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
    );
  }
}

class ProductionDashboard extends StatelessWidget {
  const ProductionDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionManager();
    final user = session.getCurrentUser();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('مدير الإنتاج - ${user?.fullName ?? ""}'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await session.logout();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductionApp()),
                  );
                }
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'خطة الإنتاج'),
              Tab(text: 'تسجيل الإنتاج'),
              Tab(text: 'كشف المقارنة'),
              Tab(text: 'سجل الإنتاج'),
              Tab(text: 'إحصائيات'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProductionPlanScreen(),
            ProductionScreen(),
            ProductionComparisonScreen(),
            ProductionListScreen(),
            ProductionStatsScreen(),
          ],
        ),
      ),
    );
  }
}