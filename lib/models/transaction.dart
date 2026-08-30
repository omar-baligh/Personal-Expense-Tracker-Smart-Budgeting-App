import 'package:flutter/material.dart';

enum TransactionType { expense, income, saving }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;
  final IconData icon;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type.name,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    TransactionType type;
    try {
      type = TransactionType.values.byName(map['type'] ?? 'expense');
    } catch (_) {
      type = TransactionType.expense;
    }

    return Transaction(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      category: map['category'] ?? '',
      type: type,
      icon: IconData(
        map['iconCodePoint'] ?? Icons.help_outline.codePoint,
        fontFamily: map['iconFontFamily'],
        fontPackage: map['iconFontPackage'],
      ),
    );
  }
}
