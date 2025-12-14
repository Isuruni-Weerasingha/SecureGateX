import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = EdgeInsets.symmetric(
      horizontal: screenSize.width * 0.1,
      vertical: screenSize.height * 0.05,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              _buildIcon(),
              const Spacer(),
              _buildTitle(),
              const SizedBox(height: 24),
              _buildSubtitle(screenSize.width),
              const Spacer(flex: 2),
              _buildButton(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C2FF).withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: const Color(0xFF00C2FF).withOpacity(0.3),
            blurRadius: 50,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF0A0F1F),
        ),
        child: const Icon(
          Icons.lock,
          size: 60,
          color: Color(0xFFC7C7C7),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Welcome to',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'SecureGate',
                style: TextStyle(
                  color: Color(0xFF00C2FF),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'X',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.8,
      child: const Text(
        'Unlock your world with the power of blockchain. Secure, seamless, and smart access to your home.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFC7C7C7),
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3EE07F).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3EE07F),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

