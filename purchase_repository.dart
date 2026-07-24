import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../../core/constants/db_constants.dart';
import '../models/purchase.dart';

class PurchaseRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<List<Purchase>> getAll() async {
    final database = await _db.database;
    final maps = await database.query(DBConstants.tablePurchases, where: 'deleted = 0');
    return maps.map((m) => Purchase.fromMap(m)).toList();
  }

  Future<void> add(Purchase purchase) async {
    final database = await _db.database;
    await database.insert(DBConstants.tablePurchases, purchase.toMap()..['id'] = _uuid.v4());
  }
}