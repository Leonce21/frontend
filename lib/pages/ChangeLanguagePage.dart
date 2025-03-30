import 'package:flutter/material.dart';

import '../components/custom_colors.dart';

class ChangeLanguagePage extends StatefulWidget {
  const ChangeLanguagePage({super.key});

  @override
  _ChangeLanguagePageState createState() => _ChangeLanguagePageState();
}

class _ChangeLanguagePageState extends State<ChangeLanguagePage> {
  String _selectedLanguage = 'French'; // Default selected language

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: CustomColors.buttonTextColor,
      appBar: AppBar(
        backgroundColor: CustomColors.buttonTextColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: CustomColors.primaryColor),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        title: Text(
          'Language',
          style: TextStyle(color: CustomColors.primaryColor,fontSize: 18,),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Image.asset(
              'assets/images/uk.png',
              width: 40, // Set the size of the flag
              height: 40,
            ),
            title: Text('Anglais'),
            trailing: Radio<String>(
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (String? value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
              activeColor: Colors.blue,
            ),
          ),
          Divider(height: 1, color: CustomColors.iconBackgroundColor),
          ListTile(
            leading: Image.asset(
              'assets/images/france.png',
              width: 40, // Set the size of the flag
              height: 40,
            ),
            title: Text('Français'),
            trailing: Radio<String>(
              value: 'French',
              groupValue: _selectedLanguage,
              onChanged: (String? value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
              activeColor: Colors.blue,
            ),
          ),
          Divider(height: 1, color: CustomColors.iconBackgroundColor),
        ],
      ),
    );
  }
}