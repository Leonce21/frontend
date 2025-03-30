import 'package:flutter/material.dart';
import '../components/custom_colors.dart';
import '../screens/LoginScreen.dart';
import '../service/api_service.dart';
import 'OTPVerificationPage.dart';

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({super.key});

  @override
  _PhoneVerificationPageState createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  // Function to verify the phone number and send OTP
  Future<void> verifyPhoneNumber() async {
    String phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez entrer un numéro valide")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool phoneExists = await ApiService.verifyPhoneNumber(phoneNumber);

      if (phoneExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Numéro trouvé! Redirection vers l'OTP...")),
        );

        // Send OTP to the phone number
        await ApiService.sendOtp(phoneNumber);

        // Redirect to OTP verification page
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPVerificationPage(
                  phoneNumber: phoneNumber,
                  isForgotPassword: true,
                ),
              ),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Numéro non trouvé.")),
        );
      }
    } catch (e) {
      print("Erreur de connexion: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion. Réessayez plus tard.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.buttonTextColor,
      appBar: AppBar(
        title: Text(
          'Vérification du Numéro',
          style: TextStyle(color: CustomColors.primaryColor),
        ),
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
              onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            ),
            ),
          ),
        backgroundColor: CustomColors.buttonTextColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/tel.png',
                  height: 300,
                ), // Placeholder for the image
                SizedBox(height: 20),
                Text(
                  'Entrez votre numéro de téléphone',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Nous vous enverrons un code de confirmation.',
                  style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 50),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+2371712663389',
                    hintStyle: TextStyle(color: CustomColors.secondaryColor),
                    prefixIcon: Icon(Icons.phone_outlined, size: 20, color: CustomColors.secondaryColor),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.secondaryColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.secondaryColor, width: 1),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _isLoading ? null : verifyPhoneNumber,
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
                  child: _isLoading
                    ? CircularProgressIndicator(
                        color: CustomColors.buttonTextColor,
                      )
                    : Text(
                        'Vérifier',
                        style: TextStyle(
                          fontSize: 18,
                          color: CustomColors.buttonTextColor,
                        ),
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
