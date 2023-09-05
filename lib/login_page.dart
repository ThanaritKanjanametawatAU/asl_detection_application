import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  // Configuration for easy adjustments
  final double topSpacing = 50.0;
  final double logoHeight = 150.0;
  final double betweenLogoAndField = 50.0;
  final double textFieldHeight = 60.0;
  final double textFieldWidth = 350.0;
  final double textFieldSpacing = 30.0;
  final double textFieldCornerRadius = 25.0;
  final double buttonHeight = 50.0;
  final double buttonWidth = 225.0;
  final double buttonCornerRadius = 25.0;
  final double buttonSpacing = 60.0;
  final double bottomSpacing = 60.0;

  final double textFieldFontSize = 16.0;
  final double buttonFontSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,  // Aligned to center
                  children: [
                    SizedBox(height: topSpacing),

                    // Logo
                    Container(
                      height: logoHeight,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/Logo.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: betweenLogoAndField),

                    // Username TextField
                    Container(
                      width: textFieldWidth,  // Set text field width
                      height: textFieldHeight,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize: textFieldFontSize),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(textFieldCornerRadius),
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    SizedBox(height: textFieldSpacing),

                    // Password TextField
                    Container(
                      width: textFieldWidth,  // Set text field width
                      height: textFieldHeight,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(fontSize: textFieldFontSize),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(textFieldCornerRadius),
                          ),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: buttonSpacing),

                    // Login Button
                    Container(
                      height: buttonHeight,
                      width: buttonWidth,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/camera');
                        },
                        child: Text('Login', style: TextStyle(fontSize: buttonFontSize)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(buttonCornerRadius),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: bottomSpacing),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
