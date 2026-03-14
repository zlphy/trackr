import 'package:equatable/equatable.dart';

class Expense extends Equatable {
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

  const Expense({
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

  @override
  List<Object?> get props => [
        id,
        merchantName,
        category,
        amount,
        date,
        receiptImagePath,
        receiptText,
        notes,
        createdAt,
        updatedAt,
      ];

  Expense copyWith({
    String? id,
    String? merchantName,
    String? category,
    double? amount,
    DateTime? date,
    String? receiptImagePath,
    String? receiptText,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      receiptText: receiptText ?? this.receiptText,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchantName': merchantName,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'receiptImagePath': receiptImagePath,
      'receiptText': receiptText,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      merchantName: json['merchantName'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      receiptImagePath: json['receiptImagePath'] as String?,
      receiptText: json['receiptText'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
