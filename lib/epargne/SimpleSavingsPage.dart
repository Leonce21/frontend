import 'package:epargne_plus/epargne/SimpledoSaving.dart';
import 'package:epargne_plus/service/api_service.dart';
import 'package:flutter/material.dart';
import '../components/custom_colors.dart';
class EpargneSimplePage extends StatefulWidget {
  final String amount;
  final String bankName;
  final String savingType;

  const EpargneSimplePage({
    super.key,
    required this.amount,
    required this.bankName,
    required this.savingType,
  });

  @override
  _EpargneSimplePageState createState() => _EpargneSimplePageState();
}

class _EpargneSimplePageState extends State<EpargneSimplePage> {
  String errorMessage = '';
  List<dynamic> transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchSimpleSavings();
  }

  Future<String> _getBankName(String bankId) async {
    try {
      final response = await ApiService.getBankById(bankId);
      if (response['success'] == true) {
        return response['data']['name'] ?? 'Bank $bankId';
      }
      return 'Bank $bankId';
    } catch (e) {
      return 'Bank loading...';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _fetchSimpleSavings() async {
    try {
      final response = await ApiService.getLastSaving();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List<dynamic>) {
          setState(() {
            transactions = data.where((t) =>t['savingType']?.toString().toLowerCase() == 'simple')
                .toList();
          });
        } else {
          setState(() {
            errorMessage = "Data format is invalid.";
          });
        }
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load transactions';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.buttonTextColor,
      appBar: AppBar(
        backgroundColor: CustomColors.buttonTextColor,
        title: Text(
          'Mes épargnes simples',
          style: TextStyle(
            color: CustomColors.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
       
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: CustomColors.primaryColor),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSimpleSavings,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                SizedBox(height: 20),
                _buildTransactionList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final bankId = transaction['bankId']?.toString() ?? '';
        return FutureBuilder<String>(
          future: _getBankName(bankId),
          builder: (context, snapshot) {
            final bankName = snapshot.data ?? 'Bank $bankId';
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Type: ${transaction['savingType'] ?? 'N/A'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${transaction['amount']?.toString() ?? '0'} FCFA',
                            style: TextStyle(color: CustomColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Banque: $bankName'),
                        Chip(
                          label: Text(transaction['status'] ?? 'N/A', style: const TextStyle(color: Colors.white)),
                          backgroundColor: transaction['status'] == 'PENDING' ? Colors.orange : Colors.green,
                        ),
                        
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date: ${_formatDate(transaction['createAt'] ?? 'N/A')}', style: const TextStyle(color: Colors.grey)),
                        
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SimpledoSaving(
                              accountId: transaction['accountId'].toString(),
                              internalId: transaction['internalId'].toString(), 
                            )),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.buttonBackgroundColor,
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            textStyle: TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Faire un depot',
                            style: TextStyle(color: CustomColors.buttonTextColor),
                          ),
                        ),
                      ]
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
