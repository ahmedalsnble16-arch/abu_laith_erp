import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../../core/constants/db_constants.dart';
import '../models/supplier.dart';

class SupplierRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<List<Supplier>> getAll() async {
    final database = await _db.database;
    final maps = await database.query(DBConstants.tableSuppliers, where: 'deleted = 0');
    return maps.map((m) => Supplier.fromMap(m)).toList();
  }

  Future<void> add(Supplier supplier) async {
    final database = await _db.database;
    await database.insert(DBConstants.tableSuppliers, supplier.toMap()..['id'] = _uuid.v4());
  }
}