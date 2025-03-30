import 'package:epargne_plus/service/api_service.dart';
import 'package:flutter/material.dart';

import '../components/custom_colors.dart';

class WithdrawalDetailsPage extends StatefulWidget {
  final String accountId;
  final String processingId;
  final double totalAmount;
  final double totalClientWithdraw;
  final double totalInterest;
  final double interest;
  final double interestPenalty;
  final double minimalAccountAmount;

  const WithdrawalDetailsPage({
    Key? key,
    required this.accountId,
    required this.processingId,
    required this.totalAmount,
    required this.totalClientWithdraw,
    required this.totalInterest,
    required this.interest,
    required this.interestPenalty,
    required this.minimalAccountAmount,
  }) : super(key: key);

  @override
  _WithdrawalDetailsPageState createState() => _WithdrawalDetailsPageState();
}

class _WithdrawalDetailsPageState extends State<WithdrawalDetailsPage> {
  bool _isLoading = false;

  Future<void> _initiateWithdrawal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.initWithdraw(
        processingId: widget.processingId,
        accountId: widget.accountId,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['meta']['statusCode'] == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Succès'),
            content: Text(response['meta']['message'] ?? 'Retrait initié avec succès!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to previous page
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Échec'),
            content: Text(response['meta']['message'] ?? 'Échec du retrait.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur'),
          content: Text('Une erreur est survenue: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du retrait'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: CustomColors.primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        backgroundColor: CustomColors.buttonTextColor,
      ),
      backgroundColor: CustomColors.buttonTextColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildDetailItem('Account ID', widget.accountId),
            // _buildDetailItem('Processing ID', widget.processingId),
            Divider(height: 30),
            _buildDetailItem('Montant total', '${widget.totalAmount} FCFA'),
            _buildDetailItem('Montant disponible', '${widget.totalClientWithdraw} FCFA'),
            _buildDetailItem('Intérêt total', '${widget.totalInterest} FCFA'),
            _buildDetailItem('Intérêt', '${widget.interest} FCFA'),
            _buildDetailItem('Pénalité d\'intérêt', '${widget.interestPenalty} FCFA'),
            _buildDetailItem('Montant minimal', '${widget.minimalAccountAmount} FCFA'),
            SizedBox(height: 30),
            Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _initiateWithdrawal,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.buttonBackgroundColor,
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 100,
                          ),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      child: Text('Confirmer le retrait',style: TextStyle(color: CustomColors.buttonTextColor),),
                      
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}