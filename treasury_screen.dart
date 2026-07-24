import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../data/repositories/treasury_repository.dart';

class TreasuryScreen extends StatefulWidget {
  const TreasuryScreen({super.key});

  @override
  State<TreasuryScreen> createState() => _TreasuryScreenState();
}

class _TreasuryScreenState extends State<TreasuryScreen> {
  final TreasuryRepository _repo = TreasuryRepository();
  double _balance = 0;
  double _todayReceipts = 0;
  double _todayPayments = 0;
  List<dynamic> _allTransactions = [];
  List<dynamic> _filteredTransactions = [];
  bool _isLoading = true;
  String _filter = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _balance = await _repo.getCurrentBalance();
      _todayReceipts = await _repo.getTodayReceipts();
      _todayPayments = await _repo.getTodayPayments();
      _allTransactions = await _repo.getAll();
      _applyFilter();
    } catch (e) {
      // ignore
    }
    setState(() => _isLoading = false);
  }

  void _applyFilter() {
    if (_filter == 'الكل') {
      _filteredTransactions = _allTransactions;
    } else {
      _filteredTransactions = _allTransactions.where((t) => t.transactionType == _filter).toList();
    }
  }

  Future<void> _showAddDialog({required String type}) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == 'قبض' ? 'سند قبض' : 'سند صرف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'المبلغ'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'البيان'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) return;
              if (type == 'قبض') {
                await _repo.addReceipt(amount: amount, note: noteController.text);
              } else {
                await _repo.addPayment(amount: amount, note: noteController.text);
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الخزنة')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // بطاقات الملخص
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _buildSummaryCard('الرصيد', _balance, AppTheme.primaryColor),
                      _buildSummaryCard('قبض اليوم', _todayReceipts, AppTheme.successColor),
                      _buildSummaryCard('صرف اليوم', _todayPayments, AppTheme.errorColor),
                    ],
                  ),
                ),
                // أزرار القبض والصرف
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddDialog(type: 'قبض'),
                      icon: const Icon(Icons.add),
                      label: const Text('قبض'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddDialog(type: 'صرف'),
                      icon: const Icon(Icons.remove),
                      label: const Text('صرف'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // أزرار الفلترة
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterChip('الكل'),
                    const SizedBox(width: 8),
                    _buildFilterChip('قبض'),
                    const SizedBox(width: 8),
                    _buildFilterChip('صرف'),
                  ],
                ),
                const Divider(),
                // قائمة المعاملات المالية
                Expanded(
                  child: _filteredTransactions.isEmpty
                      ? const Center(child: Text('لا توجد معاملات'))
                      : ListView.builder(
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final t = _filteredTransactions[index];
                            final isReceipt = t.transactionType == 'قبض';
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isReceipt
                                      ? AppTheme.successColor.withAlpha(30)
                                      : AppTheme.errorColor.withAlpha(30),
                                  child: Icon(
                                    isReceipt ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: isReceipt ? AppTheme.successColor : AppTheme.errorColor,
                                  ),
                                ),
                                title: Text(t.note ?? 'بدون بيان'),
                                subtitle: Text('${t.transactionDate} | ${t.sourceModule ?? ''}'),
                                trailing: Text(
                                  '${t.amount}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isReceipt ? AppTheme.successColor : AppTheme.errorColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor)),
              const SizedBox(height: 4),
              Text('${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filter = label;
          _applyFilter();
        });
      },
      selectedColor: AppTheme.primaryColor.withAlpha(30),
      checkmarkColor: AppTheme.primaryColor,
    );
  }
}