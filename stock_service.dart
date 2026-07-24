import '../repositories/stock_repository.dart';

class StockService {
  final StockRepository _repository = StockRepository();

  Future<List<Map<String, dynamic>>> getStockWithProductName({String? search}) async {
    return await _repository.getStockWithProductName(search: search);
  }

  Future<bool> deductStock(String productId, int quantity) async {
    return await _repository.deductStock(productId, quantity);
  }

  Future<void> addStock(String productId, int quantity) async {
    await _repository.addStock(productId, quantity);
  }

  Future<void> logMovement({
    required String productId,
    required String movementType,
    required int quantity,
    String? referenceId,
    String? referenceType,
    String? notes,
  }) async {
    await _repository.logMovement(
      productId: productId,
      movementType: movementType,
      quantity: quantity,
      referenceId: referenceId,
      referenceType: referenceType,
      notes: notes,
    );
  }
}