import 'package:flutter/material.dart';
import '../components/custom_colors.dart';
import '../service/api_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<dynamic> transactions = [];
  bool isLoading = true;
  String errorMessage = '';
  String _currentSort = 'date'; // Default sort by date
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _fetchLastTransactions();
  }

  void _sortTransactions(String sortBy) {
    setState(() {
      if (_currentSort == sortBy) {
        // Toggle direction if same sort is selected
        _sortAscending = !_sortAscending;
      } else {
        // New sort type, default to descending
        _currentSort = sortBy;
        _sortAscending = false;
      }

      switch (sortBy) {
        case 'status':
          transactions.sort((a, b) {
            final statusA = a['status']?.toString() ?? '';
            final statusB = b['status']?.toString() ?? '';
            return _sortAscending 
                ? statusA.compareTo(statusB)
                : statusB.compareTo(statusA);
          });
          break;
        case 'date':
          transactions.sort((a, b) {
            final dateA = DateTime.tryParse(a['createAt'] ?? '') ?? DateTime(0);
            final dateB = DateTime.tryParse(b['createAt'] ?? '') ?? DateTime(0);
            return _sortAscending 
                ? dateA.compareTo(dateB)
                : dateB.compareTo(dateA);
          });
          break;
        case 'amount':
          transactions.sort((a, b) {
            final amountA = a['amount'] as int? ?? 0;
            final amountB = b['amount'] as int? ?? 0;
            return _sortAscending 
                ? amountA.compareTo(amountB)
                : amountB.compareTo(amountA);
          });
          break;
      }
    });
  }

  Future<void> _fetchLastTransactions() async {
    try {
      final response = await ApiService.getLastSaving();
      if (response['success'] == true) {
        setState(() {
          transactions = response['data'] ?? [];
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
        errorMessage = 'Aucune transaction: ${e.toString()}';
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
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: CustomColors.buttonTextColor,
        appBar: AppBar(
          backgroundColor: CustomColors.buttonTextColor,
          toolbarHeight: 80,
          automaticallyImplyLeading: false,
          title: Text(
            'Historique de transaction',
            style: TextStyle(
              color: CustomColors.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _fetchLastTransactions,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                _buildSortButton(),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (errorMessage.isNotEmpty)
                  Center(child: Text(errorMessage))
                else if (transactions.isEmpty)
                  const Center(child: Text('No transactions found'))
                else
                  _buildTransactionList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher des transactions...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: PopupMenuButton<String>(
        onSelected: _sortTransactions,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'status',
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: _currentSort == 'status' 
                      ? Colors.blue 
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text('By Status'),
                if (_currentSort == 'status')
                  Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.blue,
                  ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'date',
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _currentSort == 'date' 
                      ? Colors.blue 
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text('By Date'),
                if (_currentSort == 'date')
                  Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.blue,
                  ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'amount',
            child: Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  color: _currentSort == 'amount' 
                      ? Colors.blue 
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text('By Amount'),
                if (_currentSort == 'amount')
                  Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.blue,
                  ),
              ],
            ),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Trier par',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: Colors.blue),
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
                        Text(
                          'Type: ${transaction['savingType'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${transaction['amount']?.toString() ?? '0'} FCFA',
                          style: TextStyle(
                            color: CustomColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Banque: $bankName'),
                        Chip(
                          label: Text(
                            transaction['status'] ?? 'N/A',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: transaction['status'] == 'PENDING'
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${_formatDate(transaction['createAt'] ?? 'N/A')}',
                      style: const TextStyle(color: Colors.grey),
                    ),
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
