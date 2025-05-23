import 'package:flutter/material.dart';
import 'customerLoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home/customerMainPage.dart';

class CustomerSignUpPage extends StatefulWidget {
  @override
  _CustomerSignUpPageState createState() => _CustomerSignUpPageState();
}

class _CustomerSignUpPageState extends State<CustomerSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController(); // Added
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _signUp() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      print("🟣 Form validated");

      try {
        final email = _emailController.text.trim();
        print("📨 Email: $email");

        final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
          email,
        );
        print("📩 Sign-in methods: $methods");

        if (methods.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email is already registered')),
          );
          setState(() => _isLoading = false);
          print("⚠️ Email already registered");
          return;
        }

        print("🔐 Creating Firebase Auth user...");
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email,
              password: _passwordController.text,
            );
        print("✅ User created: ${credential.user?.uid}");

        if (credential.user == null) {
          throw Exception("User creation failed — user is null");
        }
        print("📤 Saving user info to Firestore...");

        await FirebaseFirestore.instance
            .collection('customers')
            .doc(credential.user!.uid)
            .set({
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
              'email': email,
              'phoneNumber': _phoneNumberController.text.trim(), // Added
              'role': 'customer',
              'createdAt': Timestamp.now(),
            });

        print("📝 Customer data saved to Firestore");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign up successful')));

        print("➡️ Navigating to CustomerMainPage...");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => CustomerMainPage()),
          (route) => false,
        );
        print("✅ Should be on CustomerMainPage now");
      } catch (e) {
        print('❌ Error during sign-up: $e');
        String errorMessage = 'Something went wrong';

        if (e is FirebaseAuthException) {
          print("⚠️ FirebaseAuthException: ${e.code} - ${e.message}");
          if (e.code == 'weak-password') {
            errorMessage = 'Password should be at least 6 characters';
          } else if (e.code == 'email-already-in-use') {
            errorMessage = 'Email is already registered';
          } else {
            errorMessage = e.message ?? 'Authentication error';
          }
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } finally {
        setState(() => _isLoading = false);
        print("⏹ Loading state reset");
      }
    } else {
      print("❌ Form validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 80),
              Text(
                'Marden Hub\nSign Up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => CustomerLoginPage()),
                  );
                },
                child: Text("Already have an account? Log in."),
              ),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_firstNameController, 'First Name'),
                    _buildTextField(_lastNameController, 'Last Name'),
                    _buildTextField(_emailController, 'Email'),
                    _buildTextField(
                      _phoneNumberController,
                      'Phone Number',
                      isNumber: true,
                    ), // Added
                    _buildTextField(
                      _passwordController,
                      'Password',
                      isPassword: true,
                    ),
                    _buildTextField(
                      _confirmPasswordController,
                      'Confirm Password',
                      isPassword: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                      ),
                      child:
                          _isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text('Sign Up'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    bool isNumber = false,
  }) {
    bool isObscure =
        isPassword &&
        ((label == 'Password' && !_isPasswordVisible) ||
            (label == 'Confirm Password' && !_isConfirmPasswordVisible));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isNumber
                ? TextInputType.phone
                : (label == 'Email'
                    ? TextInputType.emailAddress
                    : TextInputType.text),
        obscureText: isObscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      (label == 'Password' && _isPasswordVisible) ||
                              (label == 'Confirm Password' &&
                                  _isConfirmPasswordVisible)
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        if (label == 'Password') {
                          _isPasswordVisible = !_isPasswordVisible;
                        } else if (label == 'Confirm Password') {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        }
                      });
                    },
                  )
                  : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter $label';
          if (label == 'Email' && !value.contains('@')) {
            return 'Enter a valid email address';
          }
          if (label == 'Password' && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          if (label == 'Confirm Password' &&
              value != _passwordController.text) {
            return 'Passwords do not match';
          }
          if (label == 'Phone Number' && value.length < 10) {
            return 'Enter a valid phone number';
          }
          return null;
        },
      ),
    );
  }
}
