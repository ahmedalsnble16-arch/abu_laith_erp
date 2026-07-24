import '../models/expense.dart';
import '../repositories/expense_repository.dart';

class ExpenseService {
  final ExpenseRepository _repository = ExpenseRepository();

  Future<List<Expense>> getAllExpenses({String? dateFilter}) async {
    return await _repository.getAll(dateFilter: dateFilter);
  }

  Future<Expense?> getExpenseById(String id) async {
    final expenses = await _repository.getAll();
    try {
      return expenses.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addExpense(Expense expense) async {
    await _repository.add(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await _repository.update(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _repository.delete(id);
  }

  Future<double> getTodayTotal() async {
    return await _repository.getTodayTotal();
  }
}