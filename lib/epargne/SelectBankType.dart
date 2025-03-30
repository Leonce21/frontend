import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/custom_colors.dart';
import '../service/api_service.dart';
import 'BlockedSavingsPage.dart';
import 'GoalBasedSavingsPage.dart';
import 'SimpleSavingsPage.dart';

class SelectBankType extends StatefulWidget {
  const SelectBankType({super.key});

  @override
  _SelectBankTypeState createState() => _SelectBankTypeState();
}

class _SelectBankTypeState extends State<SelectBankType> {
  final TextEditingController _amountController = TextEditingController();
  DateTime? _amountDate;
  List<Map<String, dynamic>> _banks = [];
  DateTime? _dueDate;
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _goalamountController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _periodicity;
  List<Map<String, String>> _savings = [];
  String? _selectedBankId; // Now storing bank ID instead of name
  String? _selectedBankName; // Added to display bank name
  String? _selectedSavingType;

  @override
  void initState() {
    super.initState();
    _fetchBanks();
    _fetchSavings();
    _logSavedData();
  }

  Future<void> _logSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('--- Saved Data in SharedPreferences ---');

    // Log simple savings data
    if (prefs.containsKey('epargnesimpleamount')) {
      print('Simple Savings:');
      print('Amount: ${prefs.getString('epargnesimpleamount')}');
    }

    // Log blocked savings data
    if (prefs.containsKey('epargnebloqueamount')) {
      print('Blocked Savings:');
      print('Amount: ${prefs.getString('epargnebloqueamount')}');
      print('Due Date: ${prefs.getString('epargnebloqueduedate')}');
    }

    // Log goal savings data
    if (prefs.containsKey('epargneobjectifamount')) {
      print('Goal Savings:');
      print('Amount: ${prefs.getString('epargneobjectifamount')}');
      print('Amount Date: ${prefs.getString('epargneobjectifamountdate')}');
      print('Due Date: ${prefs.getString('epargneobjectifduedate')}');
      print('Periodicity: ${prefs.getString('epargneobjectifperiodicity')}');
    }

    // Log common data
    if (prefs.containsKey('selectedBank') ||
        prefs.containsKey('selectedSavingType')) {
      print('Common Data:');
      print('Bank: ${prefs.getString('selectedBank')}');
      print('Saving Type: ${prefs.getString('selectedSavingType')}');
    }

    print('--------------------------------------');
  }

  Future<void> _fetchBanks() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> banks = await ApiService.getAllBanks();
      setState(() => _banks = banks);
    } catch (e) {
      _showError("Failed to fetch banks.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSavings() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, String>> savings = await ApiService.getAllSavings();
      print('--- Fetched Savings Types ---');
      for (var item in savings) {
        print('Type: ${item['type']}, Description: ${item['description']}');
      }
      print('----------------------------');
      setState(() => _savings = savings);
    } catch (e) {
      _showError("Failed to fetch savings.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _submitData() async {
    setState(() => _isSubmitting = true);
    print('--- _submitData() called ---');
    if (_selectedBankId == null ||
        _selectedBankName == null ||
        _selectedSavingType == null) {
      _showError("Please select a bank and saving type");
      return;
    }

    // Validate based on saving type
    if (_selectedSavingType == 'épargne bloquée' && _dueDate == null) {
      _showError("Veuillez sélectionner une date d'échéance");
      return;
    }

    if (_selectedSavingType == 'épargne par objectif') {
      int filledFields = 0;
      if (_amountController.text.isNotEmpty) filledFields++;
      if (_goalamountController.text.isNotEmpty) filledFields++;
      if (_dueDate != null) filledFields++;

      if (filledFields < 2) {
        _showError("Veuillez remplir au moins deux champs");
        return;
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      // Get common data
      String? phoneNumber = prefs.getString("phoneNumber");
      if (phoneNumber == null) {
        _showError("Phone number not found. Please login again.");
        return;
      }

      // Prepare the data for API request
      int amount = int.tryParse(_amountController.text) ?? 0;
      int? goalAmount =
          _goalamountController.text.isNotEmpty
              ? int.tryParse(_goalamountController.text)
              : null;
      String? dueDate = _dueDate?.toIso8601String().split('T')[0];

      // Call the API to create saving
      final result = await ApiService.createSaving(
        bankId: _selectedBankId!,
        phoneNumber: phoneNumber,
        savingType: _selectedSavingType!,
        amount: amount,
        goalAmount: goalAmount,
        dueDate: _dueDate?.toIso8601String().split('T')[0],
        periodicity: _periodicity,
      );

      // Prepare the data structure based on saving type
      Map<String, dynamic> savingData = {
        "bankId": _selectedBankId!,
        "bankName": _selectedBankName!,
        "phoneNumber": phoneNumber,
        "savingType": _selectedSavingType!,
      };

      if (result["success"] == true) {
        // Save common data
        await prefs.setString('selectedBankId', _selectedBankId!);
        await prefs.setString('selectedBankName', _selectedBankName!);
        await prefs.setString('selectedSavingType', _selectedSavingType!);

        // Clear all previous data first to avoid conflicts
        await Future.wait([
          prefs.remove('epargnesimpleamount'),
          prefs.remove('epargnebloqueamount'),
          prefs.remove('epargnebloqueduedate'),
          prefs.remove('epargneobjectifamount'),
          prefs.remove('epargneobjectifgoalamount'),
          prefs.remove('epargneobjectifduedate'),
          prefs.remove('epargneobjectifperiodicity'),
        ]);

        // Save specific data based on saving type
        switch (_selectedSavingType) {
          case 'epargne simple':
            savingData["amount"] = int.tryParse(_amountController.text) ?? 0;
            await prefs.setString(
              'epargnesimpleamount',
              _amountController.text,
            );
            break;

          case 'épargne bloquée':
            savingData["amount"] = int.tryParse(_amountController.text) ?? 0;
            savingData["dueDate"] = _dueDate!.toIso8601String().split('T')[0];
            await prefs.setString(
              'epargnebloqueamount',
              _amountController.text,
            );
            await prefs.setString(
              'epargnebloqueduedate',
              _dueDate!.toIso8601String().split('T')[0],
            );
            break;

          case 'épargne par objectif':
            savingData["amount"] = int.tryParse(_amountController.text) ?? 0;
            if (_goalamountController.text.isNotEmpty) {
              savingData["goalAmount"] =
                  int.tryParse(_goalamountController.text) ?? 0;
              await prefs.setString(
                'epargneobjectifgoalamount',
                _goalamountController.text,
              );
            }
            if (_dueDate != null) {
              savingData["dueDate"] = _dueDate!.toIso8601String().split('T')[0];
              await prefs.setString(
                'epargneobjectifduedate',
                _dueDate!.toIso8601String().split('T')[0],
              );
            }
            savingData["periodicity"] = _periodicity;
            await prefs.setString(
              'epargneobjectifamount',
              _amountController.text,
            );
            await prefs.setString('epargneobjectifperiodicity', _periodicity!);
            break;
        }

        // Log the saved data
        print('--- New Data Saved ---');
        print('Bank: $_selectedBankId');
        print('Bank Name: $_selectedBankName');
        print('Saving Type: $_selectedSavingType');
        print('Periodicity: $_periodicity');
        print('Amount: ${_amountController.text}');
        print('Goal Amount: ${_goalamountController.text}');
        if (_dueDate != null) print('Due Date: ${_dueDate?.toIso8601String()}');
        if (_amountDate != null) {
          print('Amount Date: ${_amountDate?.toIso8601String()}');
        }
        if (_periodicity != null &&
            _selectedSavingType == 'épargne par objectif') {
          print('Periodicity: $_periodicity');
        }
        print('----------------------');

        // Save the complete data structure as JSON string
        await prefs.setString('savingData', json.encode(savingData));

        print('--- Before Navigation ---');
        print('Selected Saving Type: $_selectedSavingType');
        print('Lowercase Saving Type: ${_selectedSavingType?.toLowerCase()}');
        print('----------------------');

        // Navigate to the appropriate page based on saving type
        switch (_selectedSavingType) {
          case 'SIMPLE':
            print('Navigating to EpargneSimplePage');
            try {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EpargneSimplePage(
                        amount: _amountController.text,
                        bankName: _selectedBankName ?? 'N/A',
                        savingType: _selectedSavingType ?? 'N/A',
                      ),
                ),
              );
            } catch (e) {
              print('Navigation error: $e');
            }
            break;
          case 'BLOCKED':
            print('Navigating to BloquePage');
            try {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BloquePage(
                        amount: _amountController.text,
                        savingType: _selectedSavingType ?? 'N/A',
                        bankName: _selectedBankName ?? 'N/A',
                        dueDate: _dueDate?.toIso8601String().split('T')[0],
                      ),
                ),
              );
            } catch (e) {
              print('Navigation error: $e');
            }
            break;
          case 'GOAL':
            print('Navigating to ObjectifPage');
            try {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ObjectifPage(
                        amount: _amountController.text,
                        savingType: _selectedSavingType ?? 'N/A',
                        bankName: _selectedBankName ?? 'N/A',
                        goalAmount:
                            _goalamountController.text.isNotEmpty
                                ? _goalamountController.text
                                : null,
                        dueDate: _dueDate?.toIso8601String().split('T')[0],
                        periodicity: _periodicity,
                      ),
                ),
              );
            } catch (e) {
              print('Navigation error: $e');
            }
            break;
        }
      } else {
        String errorMessage = result["error"] ?? "Failed to create saving";
        if (result["details"] != null) {
          errorMessage += "\nDetails: ${result["details"]}";
        }
        _showError(errorMessage);
      }
    } catch (e) {
      _showError("Erreur lors de l'enregistrement des données");
      print('Error saving data: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false); // Stop loading
      }
    }
  }

  Widget _periodicityDropdown(
    String label,
    String? selectedValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: CustomColors.secondaryColor)),
        DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          hint: Text('Choisir'),
          onChanged: onChanged,
          items:
              items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _bankDropdown(
    String label,
    String? selectedValue,
    List<Map<String, dynamic>> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: CustomColors.secondaryColor)),
        DropdownButton<String>(
          value: _selectedBankId,
          isExpanded: true,
          hint: Text('Choisir'),
          onChanged: (String? newValue) {
            setState(() {
              _selectedBankId = newValue;
              // Find and store the corresponding bank name
              var selectedBank = items.firstWhere(
                (bank) => bank['id'].toString() == newValue,
                orElse: () => {},
              );
              _selectedBankName = selectedBank['name']?.toString();
            });
            onChanged(newValue);
          },
          items:
              items.map<DropdownMenuItem<String>>((Map<String, dynamic> bank) {
                return DropdownMenuItem<String>(
                  value: bank['id'].toString(),
                  child: Text(bank['name'].toString()),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _savingsDropdown(
    String label,
    String? selectedValue,
    List<Map<String, String>> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: CustomColors.secondaryColor)),
        DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          hint: Text('Choisir'),
          onChanged: (val) {
            print('Selected saving type: $val'); // Add this line
            onChanged(val);
          },
          items:
              items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['type'],
                  child: Text(item['description']!),
                );
              }).toList(),
        ),
      ],
    );
  }

  List<Widget> _buildCorrespondingDropdowns(String selectedSavingType) {
    switch (selectedSavingType) {
      case 'SIMPLE':
        return [_amountInput()];
      case 'BLOCKED':
        return [
          _amountInput(),
          _datePickerInput(
            'Date d\'échéance',
            _dueDateController,
            (date) => _dueDate = date,
          ),
        ];
      case 'GOAL':
        return [
          Text(
            "NB: Choisissez deux champs parmi les suivants: montant périodique, montant objectif et date d'échéance.",
            style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 20),
          _periodicityDropdown('Périodicité*', _periodicity, [
            'Jour',
            'Semaine',
            'Mois',
            'Trimestre',
            'Semestre',
          ], (val) => setState(() => _periodicity = val!)),
          SizedBox(height: 20),
          AbsorbPointer(
            absorbing: _shouldDisablePeriodicAmountField(),
            child: Opacity(
              opacity: _shouldDisablePeriodicAmountField() ? 0.5 : 1.0,
              child: _periodicAmountInput(
                onChanged: (value) => _updateFieldStates(),
              ),
            ),
          ),
          SizedBox(height: 10),
          AbsorbPointer(
            absorbing: _shouldDisableGoalAmountField(),
            child: Opacity(
              opacity: _shouldDisableGoalAmountField() ? 0.5 : 1.0,
              child: _goalAmountInput(
                onChanged: (value) => _updateFieldStates(),
              ),
            ),
          ),
          SizedBox(height: 10),
          AbsorbPointer(
            absorbing: _shouldDisableDueDateField(),
            child: Opacity(
              opacity: _shouldDisableDueDateField() ? 0.5 : 1.0,
              child: _datePickerInput('Date d\'échéance', _dueDateController, (
                date,
              ) {
                setState(() {
                  _dueDate = date;
                  _updateFieldStates();
                });
              }),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  bool _shouldDisablePeriodicAmountField() {
    if (_selectedSavingType != 'GOAL') return false;
    return _goalamountController.text.isNotEmpty && _dueDate != null;
  }

  bool _shouldDisableGoalAmountField() {
    if (_selectedSavingType != 'GOAL') return false;
    return _amountController.text.isNotEmpty && _dueDate != null;
  }

  bool _shouldDisableDueDateField() {
    if (_selectedSavingType != 'GOAL') return false;
    return _amountController.text.isNotEmpty &&
        _goalamountController.text.isNotEmpty;
  }

  void _updateFieldStates() {
    setState(() {
      // This will trigger a rebuild and re-evaluate the disabling conditions
    });
  }

  Widget _periodicAmountInput({Function(String)? onChanged}) {
    return TextField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Montant périodique',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  Widget _goalAmountInput({Function(String)? onChanged}) {
    return TextField(
      controller: _goalamountController,
      decoration: InputDecoration(
        labelText: 'Montant de l\'objectif',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  Widget _amountInput() {
    return TextField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Montant',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _datePickerInput(
    String label,
    TextEditingController controller,
    Function(DateTime) onDateSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2101),
          );
          if (selectedDate != null) {
            setState(() {
              onDateSelected(selectedDate);
              controller.text = selectedDate.toLocal().toString().split(' ')[0];
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.buttonTextColor,
        title: Text(
          'Sélectionner une épargne',
          style: TextStyle(color: CustomColors.primaryColor, fontSize: 18),
        ),
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
      body:_isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bankDropdown(
              'Sélectionnez une banque',
              _selectedBankId,
              _banks,
              (val) {},
            ),
            SizedBox(height: 20),
            _savingsDropdown(
              'Sélectionnez le type d\'épargne',
              _selectedSavingType,
              _savings,
              (val) {
                setState(() {
                  _selectedSavingType = val;
                  _amountController.clear();
                  _dueDateController.clear();
                  _goalamountController.clear();
                });
              },
            ),
            SizedBox(height: 20),
            if (_selectedSavingType != null)
              ..._buildCorrespondingDropdowns(_selectedSavingType!),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed:_selectedBankId != null && _selectedSavingType != null? _submitData: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.buttonBackgroundColor,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 100),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isSubmitting
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(CustomColors.buttonTextColor),
                  ),
                )
                : Text(
                  'Créer',
                  style: TextStyle(color: CustomColors.buttonTextColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
