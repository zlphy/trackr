import 'package:dartz/dartz.dart';
import '../repositories/expense_repository.dart';
import '../../core/errors/failures.dart';

class CategorizeExpenseUseCase {
  final ExpenseRepository repository;

  CategorizeExpenseUseCase(this.repository);

  Future<Either<Failure, String>> call(String receiptText, double amount, String merchantName) {
    return repository.categorizeExpenseFromText(receiptText, amount, merchantName);
  }
}
