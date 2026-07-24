import 'package:uuid/uuid.dart';
import '../../core/constants/db_constants.dart';
import '../../core/database/database_helper.dart';
import '../../core/sync/sync_service.dart';
import '../models/treasury.dart';

class TreasuryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  // الحصول على جميع حركات الخزنة
  Future<List<Treasury>> getAll({String? dateFilter}) async {
    final db = await _dbHelper.database;
    String? where;
    List<dynamic>? whereArgs;

    if (dateFilter != null) {
      where = 'transaction_date = ? AND deleted = 0';
      whereArgs = [dateFilter];
    } else {
      where = 'deleted = 0';
    }

    final maps = await db.query(
      DBConstants.tableTreasury,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Treasury.fromMap(map)).toList();
  }

  // إضافة حركة مالية
  Future<String> addTransaction(Treasury transaction) async {
    final db = await _dbHelper.database;
    final id = transaction.id.isNotEmpty ? transaction.id : _uuid.v4();
    final transactionNumber = 'TXN-${DateTime.now().millisecondsSinceEpoch}';

    final data = {
      ...transaction.toMap(),
      'id': id,
      'transaction_number': transactionNumber,
    };

    await db.insert(DBConstants.tableTreasury, data);

    // إضافة إلى طابور المزامنة
    await SyncService().addToQueue(
      tableName: DBConstants.tableTreasury,
      recordId: id,
      action: 'INSERT',
      payload: data,
    );

    return id;
  }

  // قبض (إيراد)
  Future<String> addReceipt({
    required double amount,
    String? sourceModule,
    String? sourceId,
    String? note,
    String? createdBy,
  }) async {
    final now = DatabaseHelper.now;
    final transaction = Treasury(
      id: _uuid.v4(),
      transactionNumber: '',
      transactionType: 'قبض',
      amount: amount,
      sourceModule: sourceModule,
      sourceId: sourceId,
      note: note,
      transactionDate: DateTime.now().toIso8601String().substring(0, 10),
      status: 'معتمدة',
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      deviceId: 'mobile',
    );
    return await addTransaction(transaction);
  }

  // صرف (دفع)
  Future<String> addPayment({
    required double amount,
    String? sourceModule,
    String? sourceId,
    String? note,
    String? createdBy,
  }) async {
    final now = DatabaseHelper.now;
    final transaction = Treasury(
      id: _uuid.v4(),
      transactionNumber: '',
      transactionType: 'صرف',
      amount: amount,
      sourceModule: sourceModule,
      sourceId: sourceId,
      note: note,
      transactionDate: DateTime.now().toIso8601String().substring(0, 10),
      status: 'معتمدة',
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      deviceId: 'mobile',
    );
    return await addTransaction(transaction);
  }

  // رصيد الخزنة الحالي
  Future<double> getCurrentBalance() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(CASE WHEN transaction_type = 'قبض' THEN amount ELSE 0 END), 0) -
        COALESCE(SUM(CASE WHEN transaction_type = 'صرف' THEN amount ELSE 0 END), 0) as balance
      FROM ${DBConstants.tableTreasury}
      WHERE deleted = 0 AND status = 'معتمدة'
    ''');
    if (result.isEmpty) return 0;
    return (result.first['balance'] ?? 0).toDouble();
  }

  // إجمالي القبض اليوم
  Future<double> getTodayReceipts() async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM ${DBConstants.tableTreasury}
      WHERE transaction_type = 'قبض' AND transaction_date = ? AND deleted = 0
    ''', [today]);
    return (result.first['total'] ?? 0).toDouble();
  }

  // إجمالي الصرف اليوم
  Future<double> getTodayPayments() async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM ${DBConstants.tableTreasury}
      WHERE transaction_type = 'صرف' AND transaction_date = ? AND deleted = 0
    ''', [today]);
    return (result.first['total'] ?? 0).toDouble();
  }
}