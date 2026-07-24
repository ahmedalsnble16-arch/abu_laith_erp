import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'production_report_screen.dart';
import 'sales_report_screen.dart';
import 'comparison_report_screen.dart';
import 'financial_report_screen.dart';

class ReportsMenuScreen extends StatelessWidget {
  const ReportsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          _buildCard(
            context,
            icon: Icons.factory,
            title: 'تقرير الإنتاج',
            subtitle: 'الإنتاج والتالف والفاقد',
            color: Colors.deepOrange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductionReportScreen())),
          ),
          _buildCard(
            context,
            icon: Icons.shopping_cart,
            title: 'تقرير المبيعات',
            subtitle: 'مبيعات المعرض والموزعين',
            color: Colors.teal,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesReportScreen())),
          ),
          _buildCard(
            context,
            icon: Icons.compare_arrows,
            title: 'كشف المقارنة',
            subtitle: 'مقارنة الإنتاج المتوقع والفعلي',
            color: AppTheme.primaryColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComparisonReportScreen())),
          ),
          _buildCard(
            context,
            icon: Icons.account_balance,
            title: 'التقرير المالي',
            subtitle: 'الخزنة والمصروفات والأرباح',
            color: Colors.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialReportScreen())),
          ),
        ],
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
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 28, backgroundColor: color.withAlpha(30), child: Icon(icon, color: color, size: 28)),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade600), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}