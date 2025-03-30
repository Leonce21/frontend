import 'package:epargne_plus/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../components/custom_colors.dart';
import '../service/api_service.dart';
import 'ChangePasswordPage.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final bool isForgotPassword; // New parameter to determine the next page

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.isForgotPassword,
  });

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  bool _isVerifying = false; // For showing loading state
  String? _currentPhoneNumber;

  @override
  void initState() {
    super.initState();
    _initializePhoneNumber();
    _savePhoneNumber(widget.phoneNumber);
  }

  Future<void> _initializePhoneNumber() async {
    // Priority 1: Use widget.phoneNumber if provided
    if (widget.phoneNumber != null) {
      _currentPhoneNumber = widget.phoneNumber;
      await _savePhoneNumber(widget.phoneNumber!);
      return;
    }

    // Priority 2: Try to get from shared preferences
    _currentPhoneNumber = await _getPhoneNumber();

    if (_currentPhoneNumber == null) {
      // If still null, show error and go back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Numéro de téléphone introuvable")),
        );
        Navigator.pop(context);
      }
    }
  }

  // Save phone number in memory
  Future<void> _savePhoneNumber(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("phoneNumber", phoneNumber);
  }

  // Get phone number from memory
  Future<String?> _getPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("phoneNumber");
  }

  Future<void> verifyOTP() async {
    if (_currentPhoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Numéro de téléphone introuvable")),
      );
      return;
    }
    setState(() {
      _isVerifying = true;
    });

    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length < 6) {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Veuillez entrer un OTP valide")));
      return;
    }

    try {
      var response = await ApiService.verifyOTP(
        phoneNumber: _currentPhoneNumber!,
        otp: otp,
      );

      print('Response: $response');

      if (response['statusCode'] == 200 || response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "OTP Vérifié avec succès!"),
          ),
        );
        print("Phone Number Being Sent: $_currentPhoneNumber");
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      widget.isForgotPassword
                          ? ChangePasswordPage()
                          : LoginScreen(),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP invalide, veuillez réessayer.")),
        );
      }
    } catch (e) {
      print("Erreur de vérification OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Échec de la vérification OTP. Réessayez plus tard."),
        ),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> resendOTP() async {
    if (_currentPhoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Numéro de téléphone introuvable. Veuillez réessayer."),
        ),
      );
      return;
    }

    try {
      await ApiService.resendOTP(phoneNumber: _currentPhoneNumber!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("OTP renvoyé!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Échec de l'envoi de l'OTP. Réessayez plus tard."),
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
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFF4F4F4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: CustomColors.primaryColor,
              size: 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text("Vérification OTP"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/otp.png',
                  height: 300,
                ), // Placeholder for the image
                SizedBox(height: 20),
                Text(
                  'Entrez votre code de vérification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Nous avons envoyé un code de vérification à 6 chiffres à votre numéro de téléphone ${widget.phoneNumber}\n Vous pouvez vérifier vos messages',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 40,
                      height: 70,
                      child: TextField(
                        controller: _otpControllers[index],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            FocusScope.of(
                              context,
                            ).nextFocus(); // Move to next field
                          }
                        },
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isVerifying ? null : verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.buttonBackgroundColor,
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 130,
                    ),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  child:
                      _isVerifying
                          ? CircularProgressIndicator(
                            color: CustomColors.buttonTextColor,
                          ) // Show loader
                          : Text(
                            'Vérifier OTP',
                            style: TextStyle(
                              fontSize: 18,
                              color: CustomColors.buttonTextColor,
                            ),
                          ),
                ),
                SizedBox(height: 10),
                TextButton(onPressed: resendOTP, child: Text('Renvoyer OTP')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
