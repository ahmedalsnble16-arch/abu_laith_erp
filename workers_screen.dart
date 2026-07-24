import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../core/constants/db_constants.dart';
import '../../core/database/database_helper.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  List<Map<String, dynamic>> _workers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper().database;
    _workers = await db.query(DBConstants.tableWorkers, where: 'deleted = 0', orderBy: 'name ASC');
    setState(() => _isLoading = false);
  }

  Future<void> _add() async {
    final nameController = TextEditingController();
    final jobController = TextEditingController();
    final phoneController = TextEditingController();
    final salaryController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة عامل'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم *')),
              TextField(controller: jobController, decoration: const InputDecoration(labelText: 'الوظيفة')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'الهاتف')),
              TextField(controller: salaryController, decoration: const InputDecoration(labelText: 'الراتب'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final db = await DatabaseHelper().database;
              final now = DatabaseHelper.now;
              await db.insert(DBConstants.tableWorkers, {
                'id': const Uuid().v4(),
                'name': nameController.text.trim(),
                'job': jobController.text.trim(),
                'phone': phoneController.text.trim(),
                'salary': double.tryParse(salaryController.text) ?? 0,
                'hire_date': DateTime.now().toIso8601String().substring(0, 10),
                'active': 1,
                'created_at': now,
                'updated_at': now,
                'sync_status': 'Pending',
                'deleted': 0,
              });
              Navigator.pop(ctx, true);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (result == true) _load();
  }

  Future<void> _showWorkerAccount(String workerId, String workerName) async {
    final db = await DatabaseHelper().database;
    final transactions = await db.query(
      DBConstants.tableWorkerAccounts,
      where: 'worker_id = ?',
      whereArgs: [workerId],
      orderBy: 'transaction_date DESC',
    );

    final amountController = TextEditingController();
    String selectedType = 'مستحق';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('حساب: $workerName'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(controller: amountController, decoration: const InputDecoration(labelText: 'المبلغ'), keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(value: 'مستحق', child: Text('مستحق')),
                        DropdownMenuItem(value: 'سلفة', child: Text('سلفة')),
                        DropdownMenuItem(value: 'برانية', child: Text('برانية')),
                        DropdownMenuItem(value: 'راتب', child: Text('راتب')),
                        DropdownMenuItem(value: 'خصم', child: Text('خصم')),
                        DropdownMenuItem(value: 'مكافأة', child: Text('مكافأة')),
                      ],
                      onChanged: (v) => setDialogState(() => selectedType = v ?? 'مستحق'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) return;
                    final now = DatabaseHelper.now;
                    await db.insert(DBConstants.tableWorkerAccounts, {
                      'id': const Uuid().v4(),
                      'worker_id': workerId,
                      'transaction_type': selectedType,
                      'amount': amount,
                      'description': selectedType,
                      'transaction_date': DateTime.now().toIso8601String().substring(0, 10),
                      'created_at': now,
                      'sync_status': 'Pending',
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('إضافة'),
                ),
                const Divider(),
                if (transactions.isNotEmpty)
                  ...transactions.take(10).map((t) => ListTile(
                    title: Text(t['transaction_type'] ?? ''),
                    subtitle: Text(t['transaction_date'] ?? ''),
                    trailing: Text('${t['amount']}'),
                  )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العمال')),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workers.isEmpty
              ? const Center(child: Text('لا يوجد عمال'))
              : ListView.builder(
                  itemCount: _workers.length,
                  itemBuilder: (context, index) {
                    final w = _workers[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                        title: Text(w['name'] ?? ''),
                        subtitle: Text('${w['job'] ?? ""} | الراتب: ${w['salary'] ?? 0}'),
                        onTap: () => _showWorkerAccount(w['id'], w['name'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}