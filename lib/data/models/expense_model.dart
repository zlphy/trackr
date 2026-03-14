import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class ExpenseModel {
  final String id;
  final String merchantName;
  final String category;
  final double amount;
  final DateTime date;
  final String? receiptImagePath;
  final String? receiptText;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.merchantName,
    required this.category,
    required this.amount,
    required this.date,
    this.receiptImagePath,
    this.receiptText,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      merchantName: expense.merchantName,
      category: expense.category,
      amount: expense.amount,
      date: expense.date,
      receiptImagePath: expense.receiptImagePath,
      receiptText: expense.receiptText,
      notes: expense.notes,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      merchantName: merchantName,
      category: category,
      amount: amount,
      date: date,
      receiptImagePath: receiptImagePath,
      receiptText: receiptText,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
