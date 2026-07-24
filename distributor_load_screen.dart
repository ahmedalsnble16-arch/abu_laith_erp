import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../data/models/product.dart';
import '../../data/models/distributor.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/distributor_repository.dart';

class DistributorLoadScreen extends StatefulWidget {
  final String distributorId;
  final String distributorName;
  const DistributorLoadScreen({
    super.key,
    required this.distributorId,
    required this.distributorName,
  });

  @override
  State<DistributorLoadScreen> createState() => _DistributorLoadScreenState();
}

class _DistributorLoadScreenState extends State<DistributorLoadScreen> {
  final ProductRepository _productRepo = ProductRepository();
  final DistributorRepository _distRepo = DistributorRepository();
  List<Product> _products = [];
  List<Distributor> _distributors = [];
  String? _selectedDistributorId;
  String? _selectedDistributorName;
  Map<String, int> _cart = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final products = await _productRepo.getAll();
    final distributors = await _distRepo.getAll();
    setState(() {
      _products = products.where((p) => p.active).toList();
      _distributors = distributors;
      if (widget.distributorId.isNotEmpty) {
        _selectedDistributorId = widget.distributorId;
        _selectedDistributorName = widget.distributorName;
      }
      for (var p in _products) {
        _cart[p.id] = 0;
      }
      _isLoading = false;
    });
  }

  Future<void> _saveLoad() async {
    if (_selectedDistributorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر موزعاً'), backgroundColor: AppTheme.warningColor),
      );
      return;
    }
    final items = _cart.entries
        .where((e) => e.value > 0)
        .map((e) => {'productId': e.key, 'quantity': e.value})
        .toList();
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف كميات'), backgroundColor: AppTheme.warningColor),
      );
      return;
    }

    await _distRepo.createLoad(
      distributorId: _selectedDistributorId!,
      items: items,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم التحميل'), backgroundColor: AppTheme.successColor),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تحميل: ${_selectedDistributorName ?? ""}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.distributorId.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedDistributorId,
                      decoration: const InputDecoration(labelText: 'اختر الموزع'),
                      items: _distributors
                          .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                          .toList(),
                      onChanged: (val) {
                        final dist = _distributors.firstWhere((d) => d.id == val);
                        setState(() {
                          _selectedDistributorId = dist.id;
                          _selectedDistributorName = dist.name;
                        });
                      },
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final qty = _cart[product.id] ?? 0;
                      return ListTile(
                        title: Text(product.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() { if (qty > 0) _cart[product.id] = qty - 1; })),
                            Text('$qty'),
                            IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _cart[product.id] = qty + 1)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(onPressed: _saveLoad, child: const Text('حفظ التحميل')),
              ],
            ),
    );
  }
}