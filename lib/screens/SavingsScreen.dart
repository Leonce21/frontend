
import 'package:flutter/material.dart';
import '../components/custom_colors.dart';
import '../epargne/SelectBankType.dart';
import '../service/api_service.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  _SavingsScreenState createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  List<dynamic> transactions = [];
  String errorMessage = '';
   String? bankName;
  bool isLoading = true;
   Map<String, int> savingTypesCount = {};
   List<dynamic> savingsData = [];
  bool isExpanded = false;
  int savingTypeCount = 0;

  @override

  void initState() {
    _fetchSavingsData();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getDisplayType(String? savingType) {
    switch (savingType) {
      case 'SIMPLE':
        return 'Épargne simple';
      case 'BLOCKED':
        return 'Épargne bloquée';
      case 'GOAL':
        return 'Épargne par objectif';
      default:
        return 'Type inconnu';
    }
  }

  Future<void> _fetchSavingsData() async {
    try {
      final lastSavingResponse = await ApiService.getLastSaving();
      print('API Response: $lastSavingResponse');
      
      if (lastSavingResponse['success']) {
        final lastSavingData = lastSavingResponse['data'] as List<dynamic>;
        print('Raw Savings Data: $lastSavingData');
        
        if (lastSavingData.isNotEmpty) {
          final bankId = lastSavingData[0]['bankId'];
          
          final bankResponse = await ApiService.getBankById(bankId);
          if (bankResponse['success']) {
            setState(() {
              savingsData = lastSavingData;
              bankName = bankResponse['data']['name'];
              isLoading = false;
            });
            return;
          }
        }
      }
      
      setState(() {
        isLoading = false;
        errorMessage = 'Aucune donnée d\'épargne trouvée';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de chargement: ${e.toString()}';
      });
    }
  }

  

  void navigateToNewPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectBankType()),
    );
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
    backgroundColor: CustomColors.buttonTextColor,
    appBar: AppBar(
      backgroundColor: CustomColors.buttonTextColor,
      automaticallyImplyLeading: false,
      title: Text(
        'Mes Épargnes',
        style: TextStyle(
          color: CustomColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    collapsedBackgroundColor: Colors.grey[50],
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      bankName ?? 'Aucune banque trouvée',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.primaryColor,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_drop_down,
                      color: CustomColors.primaryColor,
                      size: 28,
                    ),
                    children: [
                      if (savingsData.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Aucune épargne trouvée',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      if (savingsData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: savingsData.length,
                            itemBuilder: (context, index) {
                              final saving = savingsData[index];
                              final displayType = _getDisplayType(saving['savingType']);
                              final amount = saving['amount']?.toString() ?? 'N/A';
                              final date = saving['savingType'] == 'SIMPLE' 
                                ? saving['valueDate'] 
                                : saving['dueDate'];
                              final goalAmount = saving['savingType'] == 'GOAL' 
                                ? saving['goalAmount']?.toString() 
                                : null;
                              final periodicity = saving['savingType'] == 'GOAL' 
                                ? saving['periodicity']?.toString() 
                                : null;

                              return Container(
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Type Row
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.account_balance_wallet,
                                            color: CustomColors.primaryColor,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Type:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            displayType,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: CustomColors.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      
                                      // Amount Row
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.monetization_on,
                                            color: Colors.green[600],
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Montant:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '$amount FCFA',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      
                                      // Date Row
                                      if (date != null)
                                        Row(
                                          children: [
                                            Icon(
                                              saving['savingType'] == 'SIMPLE'
                                                ? Icons.calendar_today
                                                : Icons.event_available,
                                              color: Colors.blue[600],
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              saving['savingType'] == 'SIMPLE'
                                                ? 'Date de valeur:'
                                                : 'Date d\'échéance:',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              _formatDate(date),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      
                                      // Additional fields for GOAL type
                                      if (saving['savingType'] == 'GOAL') ...[
                                        SizedBox(height: 8),
                                        if (goalAmount != null)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.flag,
                                                color: Colors.orange[600],
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Objectif:',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '$goalAmount FCFA',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.orange[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (periodicity != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.repeat,
                                                  color: Colors.purple[600],
                                                  size: 18,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Périodicité:',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  periodicity,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.purple[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: navigateToNewPage,
      backgroundColor: CustomColors.iconBackgroundColor,
      elevation: 4,
      child: Icon(Icons.add, color: CustomColors.primaryColor),
    ),
  );
}
}