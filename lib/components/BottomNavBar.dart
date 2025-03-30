import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/custom_colors.dart';
import '../screens/HomeScreen.dart';
import '../screens/SavingsScreen.dart';
import '../screens/SettingsScreen.dart';
import '../screens/TransactionsScreen.dart';


class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    SavingsScreen(),
    TransactionsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: _screens[_selectedIndex],
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: CustomColors.iconBackgroundColor,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: CustomColors.buttonBackgroundColor,
        unselectedItemColor: CustomColors.secondaryColor,
        type: BottomNavigationBarType.fixed,
        items: const[
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.house), label: 'Accueil'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.bank), label: 'Mes épargnes'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.rightLeft), label: 'Transactions'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.gear), label: 'Paramètres'),
        ],
      ),
    );
  }
}
