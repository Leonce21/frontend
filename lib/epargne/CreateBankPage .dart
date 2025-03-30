import 'package:flutter/material.dart';
import '../components/custom_colors.dart';
import 'SelectBankType.dart';

class CreateBankPage extends StatefulWidget {
  const CreateBankPage({super.key});

  @override
  _CreateBankPageState createState() => _CreateBankPageState();
}

class _CreateBankPageState extends State<CreateBankPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  String _periodicity = 'Jour'; // Default value
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    _dueDateController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime currentDate = DateTime.now();
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        controller.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _validateAndProceed() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SelectBankType()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.buttonTextColor,
        title: Text(
          'Créer une épargne',
          style: TextStyle(
            color: CustomColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: CustomColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: CustomColors.buttonTextColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Montant', style: TextStyle(color: CustomColors.secondaryColor)),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ex: 1000',
                    hintStyle: TextStyle(color: CustomColors.secondaryColor),
                    prefixIcon: Icon(Icons.money, size: 20, color: CustomColors.secondaryColor),
                  ),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer un montant' : null,
                ),
                SizedBox(height: 20),
                Text('Date d\'échéance', style: TextStyle(color: CustomColors.secondaryColor)),
                GestureDetector(
                  onTap: () => _selectDate(context, _dueDateController),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dueDateController,
                      decoration: InputDecoration(
                        hintText: 'Ex: 2025-12-31',
                        hintStyle: TextStyle(color: CustomColors.secondaryColor),
                        prefixIcon: Icon(Icons.calendar_today, size: 20, color: CustomColors.secondaryColor),
                      ),
                      validator: (value) => value!.isEmpty ? 'Veuillez sélectionner une date' : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text('Date de début', style: TextStyle(color: CustomColors.secondaryColor)),
                GestureDetector(
                  onTap: () => _selectDate(context, _startDateController),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: InputDecoration(
                        hintText: 'Ex: 2025-01-01',
                        hintStyle: TextStyle(color: CustomColors.secondaryColor),
                        prefixIcon: Icon(Icons.calendar_today, size: 20, color: CustomColors.secondaryColor),
                      ),
                      validator: (value) => value!.isEmpty ? 'Veuillez sélectionner une date' : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text('Périodicité', style: TextStyle(color: CustomColors.secondaryColor)),
                DropdownButtonFormField<String>(
                  value: _periodicity,
                  onChanged: (String? newValue) {
                    setState(() {
                      _periodicity = newValue!;
                    });
                  },
                  items: <String>['Jour', 'Semaine', 'Mois', 'Trimestre', 'Semestre']
                      .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  validator: (value) => value == null ? 'Veuillez sélectionner une périodicité' : null,
                ),
                SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: _validateAndProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.buttonBackgroundColor,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 130),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Suivant', style: TextStyle(color: CustomColors.buttonTextColor)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
