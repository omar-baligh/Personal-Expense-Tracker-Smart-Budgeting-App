import 'package:flutter/material.dart';

class Goal {
  final String id;
  final String title;
  final String dueDate;
  double currentAmount;
  final double targetAmount;
  final Color backgroundColor;
  final Color progressColor;
  final Color buttonColor;

  Goal({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.currentAmount,
    required this.targetAmount,
    required this.backgroundColor,
    required this.progressColor,
    required this.buttonColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': dueDate,
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
      'backgroundColor': backgroundColor.toARGB32(),
      'progressColor': progressColor.toARGB32(),
      'buttonColor': buttonColor.toARGB32(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map, String id) {
    return Goal(
      id: id,
      title: map['title'] ?? '',
      dueDate: map['dueDate'] ?? '',
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      backgroundColor: Color(map['backgroundColor'] ?? 0xFFFFFFFF),
      progressColor: Color(map['progressColor'] ?? 0xFF000000),
      buttonColor: Color(map['buttonColor'] ?? 0xFF000000),
    );
  }
}
