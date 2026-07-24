import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../../core/constants/db_constants.dart';
import '../models/raw_material.dart';

class RawMaterialRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<List<RawMaterial>> getAll({String? search}) async {
    final database = await _db.database;
    final maps = await database.query(DBConstants.tableRawMaterials, where: 'deleted = 0');
    return maps.map((m) => RawMaterial.fromMap(m)).toList();
  }

  Future<void> add(RawMaterial material) async {
    final database = await _db.database;
    await database.insert(DBConstants.tableRawMaterials, material.toMap()..['id'] = _uuid.v4());
  }
}