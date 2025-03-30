import 'package:flutter/material.dart';

import '../components/custom_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.buttonTextColor,
      appBar: AppBar(
        backgroundColor: CustomColors.buttonTextColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: CustomColors.primaryColor,
            fontSize: 18,
          ),
        ),
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            _buildNotificationItem(
              'Transaction réussie',
              'Votre transaction de XX,XX fcfa a été effectuée avec succès.',
            ),
            _buildNotificationItem(
              'Alerte de solde bas',
              'Votre solde de compte est bas : xx,xx fcfa. Veuillez envisager de faire un dépôt.',
            ),
            _buildNotificationItem(
              'Alerte de sécurité',
              'Activité inhabituelle détectée sur votre compte. Veuillez vérifier vos transactions récentes.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: CustomColors.primaryColor,
          ),
        ),
        SizedBox(height: 5),
        Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: CustomColors.primaryColor,
          ),
        ),
        Divider(height: 20, color: CustomColors.primaryColor),
      ],
    );
  }
}
