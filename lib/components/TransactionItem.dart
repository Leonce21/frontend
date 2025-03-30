// transaction_item.dart
import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final String bloqueAmount;
  final String objectifAmount;
  final String bloqueDueDate;
  final String objectifDueDate;
  final String selectedBankType;

  // const SavingsInfo({
  //   required this.bloqueAmount,
  //   required this.objectifAmount,
  //   required this.bloqueDueDate,
  //   required this.objectifDueDate,
  //   required this.selectedBankType,
  // });

  // final String title;
  // final String type;
  // final String timeAgo;
  // final String amount;
  // final Color color;

  const TransactionItem({super.key, 
    required this.bloqueAmount,
    required this.objectifAmount,
    required this.bloqueDueDate,
    required this.objectifDueDate,
    required this.selectedBankType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // CircleAvatar(backgroundColor: color, radius: 25),
              SizedBox(width: 12),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Text(
              //       title,
              //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              //     ),
              //     Text(
              //       type,
              //       style: TextStyle(color: Colors.grey[600], fontSize: 12),
              //     ),
              //   ],
              // ),
              Text(
                'Épargne Bloquée: $bloqueAmount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Date d\'échéance (Bloquée): $bloqueDueDate',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 10),
              Text(
                'Épargne par Objectif: $objectifAmount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Date d\'échéance (Objectif): $objectifDueDate',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 10),
              Text(
                'Banque Sélectionnée: $selectedBankType',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: [
          //     Text(
          //       '$amount',
          //       style: TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.w500,
          //         color: color,
          //       ),
          //     ),
          //     Text(
          //       timeAgo, // Display time ago
          //       style: TextStyle(
          //         color: Colors.grey[600],
          //         fontSize: 12,
          //         ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
