import 'package:uuid/uuid.dart';
import '../../core/constants/db_constants.dart';
import '../../core/database/database_helper.dart';
import '../models/stock.dart';

class StockRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  // جلب المخزون مع اسم المنتج
  Future<List<Map<String, dynamic>>> getStockWithProductName({String? search}) async {
    final db = await _dbHelper.database;
    
    String sql = '''
      SELECT s.*, p.name as product_name, p.unit, p.pieces_per_box
      FROM ${DBConstants.tableStock} s
      INNER JOIN ${DBConstants.tableProducts} p ON s.product_id = p.id
      WHERE p.deleted = 0
    ''';
    
    List<dynamic>? args;
    if (search != null && search.isNotEmpty) {
      sql += ' AND p.name LIKE ?';
      args = ['%$search%'];
    }
    
    sql += ' ORDER BY p.name ASC';
    
    return await db.rawQuery(sql, args);
  }

  // جلب مخزون منتج محدد
  Future<Stock?> getByProductId(String productId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DBConstants.tableStock,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    if (maps.isEmpty) return null;
    return Stock.fromMap(maps.first);
  }

  // تحديث الكمية بعد التحويل (خصم من المخزون)
  Future<bool> deductStock(String productId, int quantity) async {
    final db = await _dbHelper.database;
    final stock = await getByProductId(productId);
    if (stock == null || stock.availableQuantity < quantity) return false;
    
    await db.update(
      DBConstants.tableStock,
      {
        'quantity_pieces': stock.quantityPieces - quantity,
        'updated_at': DatabaseHelper.now,
      },
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return true;
  }

  // إضافة كمية للمخزون
  Future<void> addStock(String productId, int quantity) async {
    final db = await _dbHelper.database;
    final stock = await getByProductId(productId);
    if (stock != null) {
      await db.update(
        DBConstants.tableStock,
        {
          'quantity_pieces': stock.quantityPieces + quantity,
          'updated_at': DatabaseHelper.now,
        },
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    }
  }

  // تسجيل حركة مخزون
  Future<void> logMovement({
    required String productId,
    required String movementType,
    required int quantity,
    String? referenceId,
    String? referenceType,
    String? notes,
  }) async {
    final db = await _dbHelper.database;
    await db.insert(DBConstants.tableStockMovements, {
      'id': _uuid.v4(),
      'product_id': productId,
      'movement_type': movementType,
      'quantity': quantity,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'notes': notes,
      'created_at': DatabaseHelper.now,
      'created_by': 'admin',
      'device_id': 'mobile',
      'sync_status': 'Pending',
    });
  }
}