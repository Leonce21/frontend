import 'package:epargne_plus/screens/SignupScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/BottomNavBar.dart';
import '../components/custom_colors.dart';
import '../pages/PhoneVerificationPage.dart';
import '../service/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validate phone number format
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }

    // Basic phone number validation (adjust according to your requirements)
    final phoneRegex = RegExp(r'^\+?[0-9]{9,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }

    return null;
  }

  //Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }

    if (value.length > 8) {
      return 'Le mot de passe doit contenir au moins 12 caractères';
    }

    return null;
  }

  Future<void> _handleLogin() async {
    setState(() {_isLoggingIn = true;});
    if (_formKey.currentState!.validate()) {
      
      String phoneNumber = _phoneController.text.trim();
      String password = _passwordController.text.trim();

      try {
        var response = await ApiService.login(phoneNumber, password);
        if (response["success"] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? savedPhone = prefs.getString("phoneNumber");
          if (savedPhone == null || savedPhone.isEmpty) {
            throw Exception("Phone number storage failed");
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavBar()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response["message"] ?? "Login Failed")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.toString()}")),
        );
      }  finally{
        if(mounted) {
          setState(() {
            _isLoggingIn = false;
          });
        }
        
      }
    }
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.buttonTextColor,
      appBar: AppBar(backgroundColor: CustomColors.buttonTextColor,automaticallyImplyLeading: false,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Se connecter',
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
                  'Numero de telephone',
                  style: TextStyle(
                    fontSize: 16,
                    color: CustomColors.secondaryColor,
                  ),
                ),
                TextFormField(
                  controller: _phoneController,
                  validator: _validatePhone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+237623456789',
                    hintStyle: TextStyle(color: CustomColors.secondaryColor),
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      size: 20,
                      color: CustomColors.secondaryColor,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.iconBackgroundColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CustomColors.primaryColor,
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
                SizedBox(height: 15),
                Text(
                  'Mot de passe',
                  style: TextStyle(
                    fontSize: 16,
                    color: CustomColors.secondaryColor,
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    hintText: '********',
                    hintStyle: TextStyle(color: CustomColors.secondaryColor),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: CustomColors.secondaryColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: CustomColors.secondaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.iconBackgroundColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CustomColors.primaryColor,
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
                SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoggingIn ? null : _handleLogin,
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
                    child: _isLoggingIn
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  CustomColors.buttonTextColor),
                            ),
                          )
                        :Text(
                      'Connecter',
                      style: TextStyle(color: CustomColors.buttonTextColor),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneVerificationPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Mot de passe oublié?',
                      style: TextStyle(color: CustomColors.buttonBackgroundColor),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Je suis nouveau,',
                        style: TextStyle(color: CustomColors.secondaryColor),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'S\'inscrire',
                          style: TextStyle(
                            color: CustomColors.buttonBackgroundColor,
                          ),
                        ),
                      ),
                    ],
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
