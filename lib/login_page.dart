import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  // Configuration Constants
  static const double topSpacing = 50.0;
  static const double logoHeight = 150.0;
  static const double fieldSpacing = 50.0;
  static const double textFieldHeight = 60.0;
  static const double textFieldWidth = 350.0;
  static const double textFieldCornerRadius = 25.0;
  static const double buttonHeight = 50.0;
  static const double buttonWidth = 225.0;
  static const double buttonCornerRadius = 25.0;
  static const double buttonSpacing = 60.0;
  static const double bottomSpacing = 60.0;
  static const double textFieldFontSize = 16.0;
  static const double buttonFontSize = 18.0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: topSpacing),
                  _buildLogo(),
                  SizedBox(height: fieldSpacing),
                  _buildTextField('Username', Icons.person),
                  SizedBox(height: fieldSpacing),
                  _buildTextField('Password', Icons.lock, isPassword: true),
                  SizedBox(height: buttonSpacing),
                  _buildLoginButton(context),
                  SizedBox(height: bottomSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: logoHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Logo.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool isPassword = false}) {
    return Container(
      width: textFieldWidth,
      height: textFieldHeight,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: textFieldFontSize),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(textFieldCornerRadius),
          ),
          prefixIcon: Icon(icon),
        ),
        obscureText: isPassword,
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      height: buttonHeight,
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/camera'),
        child: Text('Login', style: TextStyle(fontSize: buttonFontSize)),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonCornerRadius),
          ),
        ),
      ),
    );
  }
}
