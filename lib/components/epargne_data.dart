// epargne_data.dart
import 'package:flutter/material.dart';

class TransactionData {
  static List<Map<String, dynamic>> transactions = [
    {
      'title': 'Épargne simple',
      'type': 'Retrait',
      'timeAgo': '20 mins ago',
      'amount': '- 5,000 F',
      'color': Colors.orange,
    },
    {
      'title': 'Épargne par objectif',
      'type': 'Retrait',
      'timeAgo': '30 mins ago',
      'amount': '- 12,000 F',
      'color': Colors.green,
    },
    {
      'title': 'Épargne par objectif',
      'type': 'Dépot',
      'timeAgo': '26 mins ago',
      'amount': '- 12,000 F',
      'color': Colors.green,
    },
    {
      'title': 'Épargne bloquée',
      'type': 'Transfer',
      'timeAgo': '1 hour ago',
      'amount': '5,000 F',
      'color': Colors.blue,
    },
  ];

  static List<Map<String, dynamic>> todayTransactions = [
    {
      'title': 'Épargne simple',
      'type': 'Retrait',
      'timeAgo': '20 mins ago',
      'amount': '- 5,000 F',
      'color': Colors.orange,
    },
    {
      'title': 'Épargne par objectif',
      'type': 'Dépot',
      'timeAgo': '35 mins ago',
      'amount': '- 12,000 F',
      'color': Colors.green,
    },
    {
      'title': 'Épargne bloquée',
      'type': 'Retrait',
      'timeAgo': '10 mins ago',
      'amount': '5,000 F',
      'color': Colors.blue,
    },
  ];

  static List<Map<String, dynamic>> yesterdayTransactions = [
    {
      'title': 'Épargne par objectif',
      'type': 'Transfer',
      'timeAgo': '1 hour ago',
      'amount': '- 12,000 F',
      'color': Colors.green,
    },
    {
      'title': 'Épargne bloquée',
      'type': 'Retrait',
      'timeAgo': '10 mins ago',
      'amount': '5,000 F',
      'color': Colors.blue,
    },
  ];

  static List<Map<String, dynamic>> epargnesimpleTransactions = [
    {
      'title': 'Épargne par objectif',
      'type': 'Transfer',
      'timeAgo': '1 hour ago',
      'amount': '- 12,000 F',
      'color': Colors.orange,
    },
    {
      'title': 'Épargne bloquée',
      'type': 'Retrait',
      'timeAgo': '10 mins ago',
      'amount': '5,000 F',
      'color': Colors.orange,
    },
  ];

  static List<Map<String, dynamic>> epargnebloqueTransactions = [
    {
      'title': 'Épargne par objectif',
      'type': 'Transfer',
      'timeAgo': '1 hour ago',
      'amount': '- 12,000 F',
      'color': Colors.blue,
    },
    {
      'title': 'Épargne bloquée',
      'type': 'Retrait',
      'timeAgo': '10 mins ago',
      'amount': '5,000 F',
      'color': Colors.blue,
    },
  ];

  static List<Map<String, dynamic>> epargneobjecifTransactions = [
    {
      'title': 'Épargne par objectif',
      'type': 'Transfer',
      'timeAgo': '1 hour ago',
      'amount': '- 12,000 F',
      'color': Colors.green,
    },
    {
      'title': 'Épargne bloquée',
      'type': 'Retrait',
      'timeAgo': '10 mins ago',
      'amount': '5,000 F',
      'color': Colors.green,
    },
  ];
}