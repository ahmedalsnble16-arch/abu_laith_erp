import '../../core/sync/sync_manager.dart';

class SyncService {
  final SyncManager _manager = SyncManager();

  Future<Map<String, dynamic>> syncAll() async {
    return await _manager.syncAll();
  }

  Future<bool> hasInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  }
}