import 'package:flutter/material.dart';

import 'custom_colors.dart';

class BouncingIcon extends StatefulWidget {
  const BouncingIcon({super.key});

  @override
  _BouncingIconState createState() => _BouncingIconState();
}

class _BouncingIconState extends State<BouncingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.2, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 80, // Set width for circular background
        height: 80, // Set height for circular background
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CustomColors.buttonTextColor, // Set desired background color for the icon
        ),
        child: IconButton(
          icon: Icon(Icons.add, color: CustomColors.primaryColor, size: 30),
          onPressed: () {
            // Add your onPressed logic here
          },
        ),
      ),
    );
  }
}