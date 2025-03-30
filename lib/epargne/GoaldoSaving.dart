import 'package:epargne_plus/epargne/GoalBasedSavingsPage.dart';
import 'package:flutter/material.dart';
import '../components/custom_colors.dart';
import '../service/api_service.dart';

class GoaldoSaving extends StatefulWidget {
  final String accountId;
  final String internalId;

  const GoaldoSaving({super.key, required this.accountId, required this.internalId});

  @override
  _GoaldoSavingState createState() => _GoaldoSavingState();
}

class _GoaldoSavingState extends State<GoaldoSaving> {
  final TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }


  Future<void> saving() async {
    setState(() => _isSubmitting = true);
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez remplir le champs"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("User Data:");
    print("Amount: ${amountController.text.trim()}");

    try {
      
      final lastSavingResponse = await ApiService.getLastSaving();

      final dataList = lastSavingResponse['data'] as List<dynamic>;
      if (dataList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No previous saving records found")),
        );
        return;
      }

      final data = dataList.first;

      final accountId = data['accountId'];
      final internalId = data['internalId'];
      print("accountId: $accountId, internalId: $internalId");

      // Call doSaving with required parameters
      var result = await ApiService.doSaving(
        amount: amountController.text.trim(),
        accountId: accountId.toString(),
        internalId: internalId.toString(),
      );

      // Ensure response follows expected schema
      if (result['meta'] != null) {
        int statusCode = result['meta']['statusCode'] ?? 500;
        String message = result['meta']['message'] ?? "Erreur inconnue";

        if (statusCode == 200) {
          // Successfully saved, navigate to EpargneSimplePage

          print("accountId: $accountId, internalId: $internalId");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ObjectifPage(
                    amount: amountController.text.trim(),
                    bankName: '',
                    savingType: 'SIMPLE',
                  ),
            ),
          );

          print("Successfully saved, navigating to EpargneSimplePage");
        } else {
          // Display error message from API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erreur: $message"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Réponse invalide du serveur"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur d'enregistrement: ${e.toString()}")),
      );
    }finally {
      if (mounted) {
        setState(() => _isSubmitting = false); // Stop loading
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.buttonTextColor,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: CustomColors.primaryColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      backgroundColor: CustomColors.buttonTextColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Faite un depot',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: CustomColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Montant du depot',
                    style: TextStyle(
                      fontSize: 16,
                      color: CustomColors.secondaryColor,
                    ),
                  ),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Entre un montant superieur a 1000',
                      hintStyle: TextStyle(
                        color: CustomColors.secondaryColor,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.money,
                        size: 20,
                        color: CustomColors.secondaryColor,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: CustomColors.secondaryColor,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: CustomColors.secondaryColor,
                          width: 1,
                        ),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1),
                      ),
                    ),
                  ),
                  // Signup Button
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: saving,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.buttonBackgroundColor,
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 110,
                        ),
                        textStyle: TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child:_isSubmitting
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(CustomColors.buttonTextColor),
                          ),
                        )
                        :  Text(
                        'Commencer',
                        style: TextStyle(color: CustomColors.buttonTextColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
