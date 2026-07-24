import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/constants/db_constants.dart';
import '../../core/database/database_helper.dart';

class ComparisonReportScreen extends StatefulWidget {
  const ComparisonReportScreen({super.key});

  @override
  State<ComparisonReportScreen> createState() => _ComparisonReportScreenState();
}

class _ComparisonReportScreenState extends State<ComparisonReportScreen> {
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery('''
      SELECT pc.*, p.name as product_name
      FROM ${DBConstants.tableProductionCompare} pc
      INNER JOIN ${DBConstants.tableProducts} p ON pc.product_id = p.id
      ORDER BY pc.compare_date DESC
      LIMIT 100
    ''');
    setState(() {
      _data = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('كشف المقارنة')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data.isEmpty
              ? const Center(child: Text('لا توجد بيانات'))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('المنتج')),
                      DataColumn(label: Text('التاريخ')),
                      DataColumn(label: Text('متوقع')),
                      DataColumn(label: Text('فعلي')),
                      DataColumn(label: Text('الفرق')),
                      DataColumn(label: Text('نسبة الفاقد')),
                    ],
                    rows: _data.map((row) {
                      final expected = row['expected_pieces'] as int? ?? 0;
                      final actual = row['actual_pieces'] as int? ?? 0;
                      final diff = row['difference'] as int? ?? 0;
                      final lossPercent = (row['loss_percent'] as num?)?.toDouble() ?? 0;
                      return DataRow(cells: [
                        DataCell(Text(row['product_name'] ?? '')),
                        DataCell(Text(row['compare_date'] ?? '')),
                        DataCell(Text('$expected')),
                        DataCell(Text('$actual')),
                        DataCell(Text('$diff', style: TextStyle(color: diff > 0 ? AppTheme.errorColor : AppTheme.successColor))),
                        DataCell(Text('${lossPercent.toStringAsFixed(1)}%', style: TextStyle(color: lossPercent > 5 ? AppTheme.errorColor : AppTheme.successColor))),
                      ]);
                    }).toList(),
                  ),
                ),
    );
  }
}