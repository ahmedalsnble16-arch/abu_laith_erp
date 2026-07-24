import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/auth/session_manager.dart';
import '../products/products_screen.dart';
import '../raw_materials/materials_screen.dart';
import '../production/production_screen.dart';
import '../warehouse/warehouse_screen.dart';
import '../showroom/showroom_screen.dart';
import '../treasury/treasury_screen.dart';
import '../expenses/expenses_screen.dart';
import '../distributors/distributors_screen.dart';
import '../reports/reports_menu_screen.dart';
import '../sync/sync_screen.dart';
import '../customers/customers_screen.dart';
import '../suppliers/suppliers_screen.dart';
import '../purchases/purchases_screen.dart';
import '../workers/workers_screen.dart';
import '../settings/settings_screen.dart';
import '../audit/audit_log_screen.dart';
import '../backup/backup_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionManager();
    final user = session.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await session.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الترحيب
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(Icons.person, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً ${user?.fullName ?? "المستخدم"}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'مدير النظام',
                            style: TextStyle(color: AppTheme.textSecondaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // عنوان الوصول السريع
            const Text(
              'الوصول السريع',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // شبكة الوصول السريع
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.95,
              children: [
                _buildCard(context, Icons.inventory_2, 'المنتجات', 'المنتجات والأسعار', AppTheme.primaryColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()))),
                _buildCard(context, Icons.grain, 'المواد الخام', 'المواد والمخزون', Colors.brown, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialsScreen()))),
                _buildCard(context, Icons.factory, 'الإنتاج', 'تسجيل الإنتاج', Colors.deepOrange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductionScreen()))),
                _buildCard(context, Icons.warehouse, 'المخزن', 'مخزن الإنتاج', AppTheme.primaryColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WarehouseScreen()))),
                _buildCard(context, Icons.store, 'المعرض', 'المبيعات والمعرض', Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShowroomScreen()))),
                _buildCard(context, Icons.account_balance_wallet, 'الخزنة', 'الحركات المالية', Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TreasuryScreen()))),
                _buildCard(context, Icons.money_off, 'المصروفات', 'المصروفات اليومية', Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()))),
                _buildCard(context, Icons.local_shipping, 'الموزعون', 'تحميل وتصفية', Colors.indigo, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DistributorsScreen()))),
                _buildCard(context, Icons.assessment, 'التقارير', 'تقارير وإحصائيات', Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsMenuScreen()))),
                _buildCard(context, Icons.people, 'العملاء', 'إدارة العملاء', Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen()))),
                _buildCard(context, Icons.business, 'الموردين', 'إدارة الموردين', Colors.deepPurple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuppliersScreen()))),
                _buildCard(context, Icons.shopping_cart, 'المشتريات', 'فواتير الشراء', Colors.blueGrey, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesScreen()))),
                _buildCard(context, Icons.badge, 'العمال', 'حسابات العمال', Colors.lightBlue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkersScreen()))),
                _buildCard(context, Icons.sync, 'المزامنة', 'مزامنة البيانات', Colors.cyan, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SyncScreen()))),
                _buildCard(context, Icons.settings, 'الإعدادات', 'إعدادات النظام', Colors.grey, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                _buildCard(context, Icons.history, 'سجل العمليات', 'سجل التدقيق', AppTheme.textSecondaryColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditLogScreen()))),
                _buildCard(context, Icons.backup, 'نسخ احتياطي', 'نسخ واستعادة', AppTheme.warningColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withAlpha(30),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}