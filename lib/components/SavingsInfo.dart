import 'package:flutter/material.dart';

class SavingsInfo extends StatelessWidget {
  final String simpleAmount;
  final String bloqueAmount;
  final String objectifAmount;
  final String bloqueDueDate;
  final String objectifDueDate;
  final String selectedBankType;
  final String selectedBank;
final String selectedSavingType;

  const SavingsInfo({super.key, 
    required this.simpleAmount,
    required this.bloqueAmount,
    required this.objectifAmount,
    required this.bloqueDueDate,
    required this.objectifDueDate,
    required this.selectedBankType,
    required this.selectedBank,
  required this.selectedSavingType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Épargne Simple: $simpleAmount',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
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
          Text('Type d’épargne sélectionné: $selectedSavingType'),
          Text('Banque sélectionnée: $selectedBank'),
        ],
      ),
    );
  }
}