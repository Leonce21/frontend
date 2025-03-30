import 'package:epargne_plus/epargne/retrait.dart';
import 'package:flutter/material.dart';
import '../components/custom_colors.dart';
import '../service/api_service.dart';

class WithdrawPage extends StatefulWidget {
  final String accountId;
  final String processingId;
  const WithdrawPage({super.key, required this.accountId, required this.processingId});

  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  late String accountId;
  late String processingId;
  List<dynamic> transactions = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLastTransactions();
    accountId = widget.accountId;
    processingId = widget.processingId;
  }
 
  Future<void> _fetchLastTransactions() async {
    try {
      final response = await ApiService.getLastSaving();
      if (response['success'] == true) {
        setState(() {
          transactions = (response['data'] ?? []).where((t) => 
            (t['status'] == 'COMPLETED' || t['status'] == 'SUCCESSFUL')
          ).toList();
          if (transactions.isNotEmpty) {
            accountId = transactions.first['accountId'] ?? widget.accountId;
            processingId = transactions.first['processingId'] ?? widget.processingId;
          } else {
            accountId = widget.accountId;
            processingId = widget.processingId;
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load transactions';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<String> _getBankName(String bankId) async {
    try {
      final response = await ApiService.getBankById(bankId);
      if (response['success'] == true) {
        return response['data']['name'] ?? 'Bank $bankId';
      }
      return 'Bank $bankId'; 
    } catch (e) {
      return 'Bank $bankId'; 
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

 
  Future<void> _navigateToWithdrawal(String accountId, String processingId) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Fetch withdrawal details from API
      final response = await ApiService.getWithdrawalDetails(accountId);
      
      // Close loading indicator
      Navigator.pop(context);

      if (response['meta']['statusCode'] == 200) {
        final withdrawalData = response['data'];
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WithdrawalDetailsPage(
              accountId: accountId,
              processingId: processingId,
              totalAmount: withdrawalData['totalAmount'] ?? 0,
              totalClientWithdraw: withdrawalData['totalClientWithdraw'] ?? 0,
              totalInterest: withdrawalData['totalInterest'] ?? 0,
              interest: withdrawalData['interest'] ?? 0,
              interestPenalty: withdrawalData['interestPenalty'] ?? 0,
              minimalAccountAmount: withdrawalData['minimalAccountAmount'] ?? 0,
            ),
          ),
        );
      } else {
        // Show error message if API call fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['meta']['message'] ?? 'Failed to load withdrawal details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading indicator if still open
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.buttonTextColor,
      appBar: AppBar(
        backgroundColor: CustomColors.buttonTextColor,
        toolbarHeight: 80,
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
        title: Text(
          'Transactions Réussies',
          style: TextStyle(
            color: CustomColors.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchLastTransactions,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      if (isLoading)
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (errorMessage.isNotEmpty)
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Text(
                              errorMessage,
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ),
                        )
                      else if (transactions.isEmpty)
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                                SizedBox(height: 16),
                                Text(
                                  'Aucune transaction réussie trouvée',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                      _buildTransactionList(),
                  
                    ],
                  ),
                ),
              ),
            ),
          ),
         
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final bankId = transaction['bankId']?.toString() ?? '';
            
            return FutureBuilder<String>(
              future: _getBankName(bankId),
              builder: (context, snapshot) {
                final bankName = snapshot.data ?? 'Banque $bankId';
                final status = transaction['status'] ?? 'N/A';
                final statusColor = _getStatusColor(status);
                
                return GestureDetector(
                  onTap: () {
                    final accountId = transaction['accountId'] ?? '';
                    final processingId = transaction['processingId'] ?? '';
                    if (accountId.isNotEmpty && processingId.isNotEmpty) {
                      _navigateToWithdrawal(accountId, processingId);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Row - Type and Amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: CustomColors.primaryColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Type:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    transaction['savingType'] ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: CustomColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${transaction['amount']?.toString() ?? '0'} FCFA',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CustomColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          
                          // Second Row - Bank and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance,
                                    color: Colors.blue[600],
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Banque:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    bankName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'SUCCÈS',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          
                          // Third Row - Date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Date:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                _formatDate(transaction['createAt'] ?? 'N/A'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          // Account ID (if needed)
                          if (transaction['accountId'] != null) ...[
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Compte:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  transaction['accountId'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}