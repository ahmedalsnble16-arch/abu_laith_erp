import 'package:uuid/uuid.dart';
import '../../core/constants/db_constants.dart';
import '../../core/database/database_helper.dart';
import '../../core/sync/sync_service.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

class SaleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  // إنشاء فاتورة بيع وتحديث المخزون والمعرض
  Future<String> createSale({
    required String? customerId,
    required String? customerName,
    required List<Map<String, dynamic>> items,
    required double discount,
    required String paymentType,
    String? createdBy,
    String? deviceId,
  }) async {
    final db = await _dbHelper.database;
    final saleId = _uuid.v4();
    final now = DatabaseHelper.now;
    final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

    double total = 0;
    for (var item in items) {
      total += (item['quantity'] as int) * (item['unitPrice'] as double);
    }
    double grandTotal = total - discount;
    if (grandTotal < 0) grandTotal = 0;

    final saleData = {
      'id': saleId,
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'total': total,
      'discount': discount,
      'grand_total': grandTotal,
      'payment_type': paymentType,
      'payment_status': paymentType == 'نقدي' ? 'مدفوعة' : 'غير مدفوعة',
      'sale_date': DateTime.now().toIso8601String().substring(0, 10),
      'status': 'معتمدة',
      'created_at': now,
      'updated_at': now,
      'created_by': createdBy,
      'device_id': deviceId,
      'sync_status': 'Pending',
      'deleted': 0,
    };

    // حفظ الفاتورة
    await db.insert(DBConstants.tableSales, saleData);

    // حفظ العناصر وتحديث مخزون المعرض
    for (var item in items) {
      final itemId = _uuid.v4();
      final productId = item['productId'] as String;
      final quantity = item['quantity'] as int;
      final unitPrice = (item['unitPrice'] as double);
      final itemTotal = quantity * unitPrice;

      await db.insert(DBConstants.tableSaleItems, {
        'id': itemId,
        'sale_id': saleId,
        'product_id': productId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total': itemTotal,
        'created_at': now,
      });

      // خصم من المعرض
      final showroomStock = await db.query(
        DBConstants.tableShowroomStock,
        where: 'product_id = ?',
        whereArgs: [productId],
      );

      if (showroomStock.isNotEmpty) {
        final currentQty = showroomStock.first['quantity'] as int? ?? 0;
        final newQty = currentQty - quantity;
        await db.update(
          DBConstants.tableShowroomStock,
          {
            'quantity': newQty < 0 ? 0 : newQty,
            'updated_at': now,
          },
          where: 'product_id = ?',
          whereArgs: [productId],
        );
      }

      // حركة المعرض
      await db.insert(DBConstants.tableShowroomMovements, {
        'id': _uuid.v4(),
        'product_id': productId,
        'movement_type': 'بيع',
        'quantity': -quantity,
        'reference_id': saleId,
        'notes': 'فاتورة $invoiceNumber',
        'created_at': now,
        'created_by': createdBy,
        'device_id': deviceId,
      });
    }

    // إذا كان نقدي، تسجيل في الخزنة
    if (paymentType == 'نقدي') {
      await db.insert(DBConstants.tableTreasury, {
        'id': _uuid.v4(),
        'transaction_number': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        'transaction_type': 'قبض',
        'amount': grandTotal,
        'source_module': 'معرض',
        'source_id': saleId,
        'note': 'فاتورة $invoiceNumber',
        'transaction_date': DateTime.now().toIso8601String().substring(0, 10),
        'status': 'معتمدة',
        'created_at': now,
        'updated_at': now,
        'created_by': createdBy,
        'device_id': deviceId,
        'sync_status': 'Pending',
      });
    }

    // إضافة إلى طابور المزامنة
    await SyncService().addToQueue(
      tableName: DBConstants.tableSales,
      recordId: saleId,
      action: 'INSERT',
      payload: saleData,
    );

    return saleId;
  }

  // الحصول على مبيعات اليوم
  Future<List<Sale>> getTodaySales() async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final maps = await db.query(
      DBConstants.tableSales,
      where: 'sale_date = ? AND deleted = 0',
      whereArgs: [today],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Sale.fromMap(map)).toList();
  }
}