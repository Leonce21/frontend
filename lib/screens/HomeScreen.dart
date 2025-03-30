import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:epargne_plus/components/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../epargne/BlockedSavingsPage.dart';
import '../epargne/GoalBasedSavingsPage.dart';
import '../epargne/SelectBankType.dart';
import '../epargne/SimpleSavingsPage.dart';
import '../service/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isAmountVisible = false;
  List<Map<String, dynamic>> _savings = [];
  double _totalBalance = 0.0;
  bool _isLoading = false;
  Map<String, dynamic>? _recentSavingsByType = {};
  

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
     _fetchRecentSavings();
     _fetchSuccessfulSavings();
  }

  String fullName = "Chargement..."; // Default loading text
  String status = "Chargement...";

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _fetchRecentSavings() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getLastSaving();
      
      if (response['meta']['statusCode'] == 200) {
        final savingsData = List<Map<String, dynamic>>.from(response['data'] ?? []);
        
        // Group savings by type and get the most recent of each type
        final recentSavingsByType = {
          'SIMPLE': savingsData.where((s) => s['savingType'] == 'SIMPLE').firstOrNull,
          'GOAL': savingsData.where((s) => s['savingType'] == 'GOAL').firstOrNull,
          'BLOCKED': savingsData.where((s) => s['savingType'] == 'BLOCKED').firstOrNull,
        };

        setState(() {
          _savings = savingsData;
          _recentSavingsByType = recentSavingsByType;
          _totalBalance = _calculateTotalBalance(_savings);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        // Handle error if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['meta']['message'] ?? 'Failed to fetch savings')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching savings: $e')),
      );
    }
  }

  Future<void> _fetchSuccessfulSavings() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await ApiService.getLastSaving();
      
      if (response['meta']?['statusCode'] == 200) {
        final List<dynamic> rawSavings = response['data'] ?? [];
        
        // Debug print to verify raw data
        print('Raw savings data: $rawSavings');
        
        // Filter and convert savings
        final List<Map<String, dynamic>> successfulSavings = rawSavings
            .where((saving) => saving['status'] == 'SUCCESSFUL')
            .map((saving) {
              final amount = saving['amount'] is int 
                  ? (saving['amount'] as int).toDouble()
                  : saving['amount']?.toDouble() ?? 0.0;
                  
              // Debug print for each saving
              print('Successful saving: ${saving['processingId']}, '
                  'Amount: $amount, Status: ${saving['status']}');
                  
              return {
                'amount': amount,
                'status': saving['status'],
                // Include other fields you need
              };
            }).toList();

        // Debug print filtered savings
        print('Successful savings count: ${successfulSavings.length}');
        
        final calculatedTotal = successfulSavings.fold(0.0, 
            (sum, saving) => sum + (saving['amount'] ?? 0.0));
        
        // Debug print final calculation
        print('Calculated total: $calculatedTotal');
        
        setState(() {
          _savings = successfulSavings;
          _totalBalance = calculatedTotal;
          _isLoading = false;
        });
      } else {
        throw Exception(response['meta']?['message'] ?? 'Failed to fetch savings');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      print('Error in _fetchSuccessfulSavings: $e');
    }
  }

  double _calculateTotalBalance(List<Map<String, dynamic>> savings) {
    return savings.fold(0.0, (sum, saving) => sum + (saving['amount'] ?? 0.0));
  }

  Future<void> fetchUserDetails() async {
    var response = await ApiService.getUserDetails();

    if (response["success"] == false) {
      // Handle error case
      print("Error fetching user details: ${response["error"]}");
      setState(() {
        fullName = "Erreur de chargement";
        status = "";
      });
    } else {
      // Process the user details
      setState(() {
        fullName = "${response['name']} ${response['surname']}";
        status = response['status'] ?? '';
      });
    }
  }

  void _navigateToSavingDetail(String savingType, Map<String, dynamic>? savingData) {
    
    final defaults = {
      'amount': 0,
      'bankName': 'N/A',
      'goalAmount': 0,
      'dueDate': 'N/A',
      'periodicity': 'N/A',
      'displayName': 'Nouvelle Épargne',
      'status': 'N/A',
      'interest': 0,
      'valueDate': 'N/A',
    };

    // Merge with actual data if exists
    final data = {...defaults, ...?savingData, 'savingType': savingType};

    switch (savingType) {
      case 'SIMPLE':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EpargneSimplePage(
              amount: data['amount'].toString(),
              bankName: data['bankName'],
              savingType: data['displayName'],
            ),
          ),
        );
        break;

      case 'BLOCKED':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BloquePage(
              amount: data['amount'].toString(),
              savingType: data['displayName'],
              bankName: data['bankName'],
              dueDate: data['dueDate'],
            ),
          ),
        );
        break;

      case 'GOAL':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ObjectifPage(
              amount: data['amount'].toString(),
              savingType: data['displayName'],
              bankName: data['bankName'],
              goalAmount: data['goalAmount'].toString(),
              dueDate: data['dueDate'].toString(),
              periodicity: data['periodicity'].toString(),
            ),
          ),
        );
        break;

      default:
       
    }
  }

  void _toggleVisibility() {
    setState(() {
      _isAmountVisible = !_isAmountVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.buttonTextColor,
      appBar: AppBar(
        backgroundColor: CustomColors.buttonTextColor,
        elevation: 0,
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/user1.png'),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 6),
            Text(
              fullName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 170,
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.blue.shade900,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Solde total',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  _isAmountVisible
                                      ? '${_totalBalance.toStringAsFixed(0)} FCFA'
                                      : '******** FCFA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 15),
                                IconButton(
                                  icon: Icon(
                                    _isAmountVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: _toggleVisibility,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Vos épargnes',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),

                    CarouselSlider.builder(
                      itemCount: 3, // SIMPLE, GOAL, BLOCKED
                      options: CarouselOptions(
                        height: 180,
                        autoPlay: true,
                        autoPlayCurve: Curves.easeIn,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                      itemBuilder: (context, index, realIndex) {
                        // Determine card type based on index
                         final savingTypes = ['SIMPLE', 'GOAL', 'BLOCKED'];
                          final savingType = savingTypes[index];
                          final saving = _recentSavingsByType?[savingType];

                        // Set up card content based on type
                        Color cardColor;
                        String displayText;
                        String amountText = saving != null 
                            ? (_isAmountVisible 
                                ? '${saving['amount']?.toString() ?? '0'} FCFA' 
                                : '********* FCFA')
                            : 'Aucune donnée';
                        
                        String additionalInfo = '';
                        String periodicityText = '';
                        String statusText = '';

                        if (saving != null) {
                          // Format periodicity if it exists
                          if (saving['periodicity'] != null) {
                            periodicityText = saving['periodicity'] == 'JOURNALIERE' 
                                ? 'Quotidienne' 
                                : saving['periodicity'] == 'HEBDOMADAIRE' 
                                    ? 'Hebdomadaire' 
                                    : saving['periodicity'] == 'MENSUELLE' 
                                        ? 'Mensuelle' 
                                        : saving['periodicity'].toString();
                          }

                          // Format status
                          statusText = saving['status'] == 'SUCCESSFUL' 
                              ? 'Réussie' 
                              : saving['status'] == 'PENDING' 
                                  ? 'En attente' 
                                  : saving['status'].toString();
                        }

                        switch (savingType) {
                          case 'SIMPLE':
                            cardColor = Colors.orange;
                            displayText = 'Épargne Simple';
                            additionalInfo = saving != null
                                ? 'Date: ${_formatDate(saving['valueDate'])}'
                                : 'Aucune épargne simple récente';
                            break;
                          case 'GOAL':
                            cardColor = Colors.green;
                            displayText = 'Épargne par Objectif';
                            if (saving != null) {
                              final amount = saving['amount'] as num?;
                              final goalAmount = saving['goalAmount'] as num?;
                              final dueDate = saving['dueDate'];
                              final periodicity = saving['periodicity']?.toString();
                              
                              // Format periodicity text if it exists
                              String formattedPeriodicity = '';
                              if (periodicity != null) {
                                // Convert to lowercase for case-insensitive comparison
                                final period = periodicity.toLowerCase();
                                
                                formattedPeriodicity = switch (period) {
                                  'journaliere' || 'jour' || 'daily' => 'Quotidienne',
                                  'hebdomadaire' || 'semaine' || 'weekly' => 'Hebdomadaire',
                                  'mensuelle' || 'mois' || 'monthly' => 'Mensuelle',
                                  'trimestrielle' || 'trimestre' || 'quarterly' => 'Trimestrielle',
                                  'semestrielle' || 'semestre' || 'biannual' => 'Semestrielle',
                                  'annuelle' || 'annuel' || 'yearly' => 'Annuelle',
                                  _ => periodicity, // Return original if no match
                                };
                                
                                // Capitalize first letter
                                if (formattedPeriodicity.isNotEmpty) {
                                  formattedPeriodicity = formattedPeriodicity[0].toUpperCase() + 
                                    formattedPeriodicity.substring(1);
                                }
                              }
                              
                              // Build the additional info based on what's available
                              List<String> infoParts = [];
                              
                              if (amount != null && amount > 0) {
                                infoParts.add('Montant: ${_isAmountVisible ? amount : '***'} FCFA');
                              }
                              
                              if (goalAmount != null && goalAmount > 0) {
                                infoParts.add('Objectif: ${_isAmountVisible ? goalAmount : '***'} FCFA');
                              }
                              
                              if (dueDate != null) {
                                infoParts.add('Date Échéance: ${_formatDate(dueDate)}');
                              }
                              
                              if (formattedPeriodicity.isNotEmpty) {
                                infoParts.add('Périodicité: $formattedPeriodicity');
                              }
                              
                              
                              additionalInfo = infoParts.isNotEmpty 
                                  ? infoParts.join('\n')
                                  : 'Aucune information disponible';
                            } else {
                              additionalInfo = 'Aucune épargne objectif récente';
                            }
                            break;
                          case 'BLOCKED':
                            cardColor = Colors.blue;
                            displayText = 'Épargne Bloquée';
                            additionalInfo = saving != null
                                ? 'Échéance: ${saving['dueDate'] != null ? _formatDate(saving['dueDate']) : 'N/A'}\n'
                                  
                                : 'Aucune épargne bloquée récente';
                            break;
                          default:
                            cardColor = Colors.grey;
                            displayText = 'Autre Type';
                        }


                        return GestureDetector(
                          onTap: () {
                            final saving = _recentSavingsByType?[savingType];
                            _navigateToSavingDetail(savingType, saving);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              // Gradient applied here
                              gradient: LinearGradient(
                                colors: [
                                  cardColor.withOpacity(saving != null ? 1.0 : 0.6),
                                  cardColor.withOpacity(saving != null ? 0.4 : 0.2),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Circular element at the top left
                                Positioned(
                                  top:
                                      10 +
                                      (index *
                                          10), // Adjust Y position based on index for randomness
                                  left:
                                      20 +
                                      (index *
                                          5), // Adjust X position based on index for randomness
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFFFEFD5).withOpacity(0.2),
                                    ),
                                    child: ClipOval(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 5.0,
                                          sigmaY: 5.0,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(
                                              0xFFFFEFD5,
                                            ).withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          displayText,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        if (savingType == 'SIMPLE' || savingType == 'BLOCKED')
                                          Text(
                                            amountText,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        SizedBox(height: 8),
                                        if (additionalInfo.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              additionalInfo,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10),

                    Center(
                      child: AnimatedSmoothIndicator(
                        activeIndex: _currentIndex,
                        count: 3,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 16,
                          activeDotColor: CustomColors.secondaryColor,
                          dotColor: CustomColors.iconBackgroundColor,
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Navigate to account creation screen
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectBankType(),
                            ),
                          );
                        },
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
                        child: Text(
                          'Créer une epargne',
                          style: TextStyle(color: CustomColors.buttonTextColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
