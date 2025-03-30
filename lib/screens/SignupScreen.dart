import 'dart:async';
import 'dart:io';
import 'package:epargne_plus/pages/TermsAndCondition.dart';
import 'package:flutter/material.dart';
import '../components/custom_colors.dart';
import '../pages/OTPVerificationPage.dart';
import '../service/api_service.dart';
import 'LoginScreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  bool _isChecked = false;
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for text input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cniNumberController = TextEditingController();
  final TextEditingController cniExpirationController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        // Format the date as YYYY-MM-DD (common API format)
        cniExpirationController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }


  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    if (nameController.text.isEmpty ||
        surnameController.text.isEmpty ||
        emailController.text.isEmpty ||
        cniNumberController.text.isEmpty ||
        cniExpirationController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez remplir tous les champs obligatoires"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez accepter les termes et conditions"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final now = DateTime.now();
    final phoneNumber = phoneNumberController.text.trim();
    final internalId =
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}'
        '${now.millisecond.toString().padLeft(4, '0')}'
        '+$phoneNumber';

    print("User Data:");
    print("Internal ID: $internalId");
    print("Name: ${nameController.text.trim()}");
    print("Surname: ${surnameController.text.trim()}");
    print("Email: ${emailController.text.trim()}");
    print("Numéro CNI: ${cniNumberController.text.trim()}");
    print("Date d'expiration CNI: ${cniExpirationController.text.trim()}");
    print("Numéro de téléphone: ${phoneNumberController.text.trim()}");

    try {

      // Check if phone number already exists
      final phoneExists = await ApiService.verifyPhoneNumber(phoneNumberController.text.trim());
      if (phoneExists) {
        throw "Le numéro de téléphone est déjà utilisé. Veuillez utiliser un autre numéro.";
      }

      
      final result = await ApiService.registerUser(
        name: nameController.text.trim(),
        surname: surnameController.text.trim(),
        email: emailController.text.trim(),
        cniNumber: cniNumberController.text.trim(),
        cniExpiration: cniExpirationController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        password: passwordController.text.trim(),
        internalId: internalId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Vous recevrez un code de 6 chiffres sur votre numéro de téléphone."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(Duration(seconds: 3));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationPage(
            phoneNumber: phoneNumberController.text.trim(),
            isForgotPassword: false,
          ),
        ),
      );

    } on SocketException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pas de connexion internet. Veuillez vérifier votre connexion."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("La requête a expiré. Veuillez réessayer."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }catch (e) {
      print("Registration error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur d'inscription: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }


  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    cniNumberController.dispose();
    cniExpirationController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(backgroundColor: CustomColors.buttonTextColor,automaticallyImplyLeading: false,),
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
                        'S\'inscrire',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: CustomColors.primaryColor,
                        ),
                      ),
                      
                    ],
                  ),
                  SizedBox(height: 30),
                  
                  // Nom et Prénoms
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nom',
                              style: TextStyle(fontSize: 16, color: CustomColors.secondaryColor),
                            ),
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                hintText: 'John',
                                hintStyle: TextStyle(color: CustomColors.secondaryColor),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: CustomColors.secondaryColor),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: CustomColors.secondaryColor, width: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prénoms',
                              style: TextStyle(fontSize: 16, color: CustomColors.secondaryColor),
                            ),
                            TextField(
                              controller: surnameController,
                              decoration: InputDecoration(
                                hintText: 'Doe',
                                hintStyle: TextStyle(color: CustomColors.secondaryColor),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: CustomColors.secondaryColor),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: CustomColors.secondaryColor, width: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
              
                  // Numero de telephone
                  Text(
                    'Numero de telephone',
                    style: TextStyle(fontSize: 16, color: CustomColors.secondaryColor),
                  ),
                  TextField(
                    controller: phoneNumberController,
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
                  SizedBox(height: 15),
              
                
                  Text(
                    'Email',
                    style: TextStyle(fontSize: 16, color: CustomColors.secondaryColor),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'example@gmail.com',
                      hintStyle: TextStyle(color: CustomColors.secondaryColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.secondaryColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.secondaryColor, width: 1),
                      ),
                    ),
                  ),
              
                  // cni expiration and cni number
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextField(
                              controller: cniExpirationController,
                              decoration: InputDecoration(
                                labelText: 'Date d\'expiration',
                                labelStyle: TextStyle(color: CustomColors.secondaryColor),
                                prefixIcon: Icon(Icons.calendar_today, color: CustomColors.secondaryColor),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: CustomColors.secondaryColor),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: CustomColors.secondaryColor, width: 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: cniNumberController,
                          decoration: InputDecoration(
                            labelText: 'Numéro CNI',
                            labelStyle: TextStyle(color: CustomColors.secondaryColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: CustomColors.secondaryColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: CustomColors.secondaryColor, width: 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              
                  SizedBox(height: 15),
              
                  // Mot de passe
                  Text(
                    'Mot de passe',
                    style: TextStyle(fontSize: 16, color: CustomColors.secondaryColor),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '********',
                      hintStyle: TextStyle(color: CustomColors.secondaryColor),
                      prefixIcon: Icon(Icons.lock_outline, size: 20, color: CustomColors.secondaryColor),
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
                        borderSide: BorderSide(color: CustomColors.secondaryColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.primaryColor, width: 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
              
                  // Terms and Conditions Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value ?? false; // Toggle checkbox state
                          });
                        },
                        activeColor: CustomColors.primaryColor,
                      ),
                      Text('J\'accepte les ', style: TextStyle(color: CustomColors.secondaryColor)),
                      GestureDetector(
                        onTap: () {
                          // Handle terms and conditions link click
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => TermsAndConditionPage()),
                          );
                        },
                        child: Text(
                          'termes et conditions',
                          style: TextStyle(color: CustomColors.buttonBackgroundColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
              
                  // Signup Button
                  Center(
                    child: ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors.buttonBackgroundColor,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 130),
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
                  :  Text(
                        'S\'inscrire',
                        style: TextStyle(color: CustomColors.buttonTextColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
              
                  // Already have an account
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Vous avez déjà un compte ?',
                          style: TextStyle(color: CustomColors.secondaryColor),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                          child: Text('Se connecter', style: TextStyle(color: CustomColors.buttonBackgroundColor)),
                        ),
                      ],
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