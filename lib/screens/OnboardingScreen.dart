import 'package:epargne_plus/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/custom_colors.dart';
import 'SignupScreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isOnboarded = prefs.getBool('isOnboarded');
    if (isOnboarded == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  _setOnboardingComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isOnboarded', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.buttonTextColor,
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildPage(
            title: 'Bienvenue chez Epargne+',
            content:
                'Epargne+ propose des formules d’épargne flexibles (simple, bloquée, avec objectif) pour les particuliers et les petites entreprises.',
            imagePath: 'assets/images/saving.png', // Update with your image path
          ),
          _buildPage(
            title: 'Choisissez Votre Formule d’Épargne',
            content:
                'Sélectionnez parmi :\n- Simple : Accès facile aux fonds.\n- Bloquée : Taux d’intérêt plus élevés avec des fonds bloqués.\n- Avec Objectif : Épargnez pour un objectif spécifique.',
            imagePath: 'assets/images/finance.png', // Update with your image path
          ),
          _buildPage(
            title: 'Transactions Sécurisées et Faciles',
            content:
                'Profitez de transactions sécurisées avec des opérateurs de monnaie électronique, respectant les normes KYC et les réglementations financières.',
            imagePath: 'assets/images/securite.png', // Update with your image path
          ),
        ],
      ),
      bottomSheet: _buildBottomNavigation(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildPage({
    required String title,
    required String content,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath), // Load image from assets
          SizedBox(height: 20),
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text(content, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSkipButton(),
          _buildDotIndicator(),
          _currentPage == 2 ? _buildSignUpButton() : _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
      },
      child: Text('Suivant',style: TextStyle(color: CustomColors.buttonBackgroundColor)),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: () {
        _setOnboardingComplete();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignupScreen()),
        );
      },
      child: Text('Commencer',style: TextStyle(color: CustomColors.buttonBackgroundColor)),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {
        _controller.jumpToPage(2);
      },
      child: Text(
        'Passer',
        style: TextStyle(color: CustomColors.buttonBackgroundColor),
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? CustomColors.buttonBackgroundColor : CustomColors.secondaryColor,
          ),
        );
      }),
    );
  }
}