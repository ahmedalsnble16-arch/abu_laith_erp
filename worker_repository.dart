import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../../core/constants/db_constants.dart';
import '../models/worker.dart';

class WorkerRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<List<Worker>> getAll() async {
    final database = await _db.database;
    final maps = await database.query(DBConstants.tableWorkers, where: 'deleted = 0');
    return maps.map((m) => Worker.fromMap(m)).toList();
  }

  Future<void> add(Worker worker) async {
    final database = await _db.database;
    await database.insert(DBConstants.tableWorkers, worker.toMap()..['id'] = _uuid.v4());
  }
}