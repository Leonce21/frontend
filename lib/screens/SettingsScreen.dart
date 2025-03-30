import 'package:epargne_plus/pages/ChangePasswordPage.dart';
import 'package:epargne_plus/pages/ProfilePage.dart';
import 'package:epargne_plus/pages/TermsAndCondition.dart';
import 'package:epargne_plus/pages/WithdrawPage.dart';
import 'package:flutter/material.dart';
import '../components/custom_colors.dart';
import '../pages/ChangeLanguagePage.dart';
import 'LoginScreen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.buttonTextColor,
      appBar: AppBar(
        backgroundColor: CustomColors.buttonTextColor,
        automaticallyImplyLeading: false,
        title: Text(
          'Paramètres',
          style: TextStyle(
            color: CustomColors.primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF4F4F4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.logout_outlined, color: CustomColors.primaryColor),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirmation"),
                        content: Text("Vous êtes sur le point de quitter Epargne+"),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Annuler"),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                          TextButton(
                            child: Text("Confirmer"),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            _buildSectionTitle('Général'),
            // _buildListTile(context, 'Langue', 'Français  '),
            _buildListTile(context, 'Mon profil', ''),
            _buildListTile(context, 'Fair un retrait', ''),
            SizedBox(height: 20),
            _buildSectionTitle('Sécurité'),
            _buildListTile(context, 'Changer mot de passe', ''),
            _buildListTile(context, 'Termes et Conditions', ''),
            // SizedBox(height: 10),
            // Text(
            //   'Choisissez quelles données vous partagez avec nous',
            //   style: TextStyle(color: Colors.grey, fontSize: 12),
            // ),
            // SwitchListTile(
            //   title: Text('Biométrique'),
            //   value: false,
            //   onChanged: (value) {
            //     // Handle biometric toggle
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: CustomColors.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, String subtitle) {
    return Column(
      children: [
        InkWell(
          splashColor:Colors.transparent, // Prevents the ripple effect from appearing again
          highlightColor:Colors.transparent, // Prevents highlighting when returning
          onTap: () {
            // Navigate to ChangeLanguagePage when the 'Langue' tile is tapped
            if (title == 'Langue') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangeLanguagePage()),
              );
            }

            // Navigate to Mon profile page when the 'Mon profil' tile is tapped
            if (title == 'Mon profil') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            }

            // Navigate to Mon profile page when the 'Mon profil' tile is tapped
            if (title == 'Fair un retrait') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WithdrawPage(accountId: '', processingId: '',)),
              );
            }

            // Navigate to Changer mot de passe page when the 'Changer mot de passe' tile is tapped
            if (title == 'Changer mot de passe') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              );
            }

            // Navigate to Termes et Conditionspage when the 'Termes et Conditions' tile is tapped
            if (title == 'Termes et Conditions') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsAndConditionPage()),
              );
            }
          },
          child: ListTile(
            title: Text(title, style: TextStyle(fontSize: 16)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: CustomColors.secondaryColor,
                      fontSize: 14,
                    ),
                  ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: CustomColors.iconBackgroundColor),
      ],
    );
  }
}
