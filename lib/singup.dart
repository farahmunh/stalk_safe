import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String selectedRegion = '+60';
  bool _isPasswordVisible = false;
  bool _isTermsChecked = false;

  final Map<String, String> regions = {
    'Malaysia (+60)': '+60',
    'Indonesia (+62)': '+62',
    'Thailand (+66)': '+66',
    'Singapore (+65)': '+65',
    'Philippines (+63)': '+63',
  };

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isUsernameUnique(String username) async {
    final querySnapshot = await _firestore
      .collection('users')
      .where('username', isEqualTo: username)
      .limit(1)
      .get();

    return querySnapshot.docs.isEmpty;
  }

  void _signUpWithEmailAndPassword() async {
    if (_formKey.currentState!.validate() && _isTermsChecked) {
      final isUnique = await isUsernameUnique(_usernameController.text.trim());
      if(!isUnique){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username is already taken.')),
        );
      }
      
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': '$selectedRegion${_phoneController.text.trim()}',
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pushNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already in use.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Password is too weak.';
        } else {
          errorMessage = 'An error occurred: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please complete the form and accept the terms and conditions.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF517E4C),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'STALKSAFE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.anton(
                      fontSize: 42,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('Username', _usernameController,
                      validator: _validateUsername),
                  _buildTextField('Email address', _emailController,
                      validator: _validateEmail),
                  _buildPhoneNumberField(),
                  _buildPasswordField(),
                  FormField<bool>(
                    initialValue: _isTermsChecked,
                    validator: (value) {
                      if (value == null || !value) {
                        return 'You must agree to the terms and conditions.';
                      }
                      return null;
                    },
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _isTermsChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isTermsChecked = value ?? false;
                                  });
                                  state.didChange(_isTermsChecked);
                                },
                              ),
                              Expanded(
                                child: Text(
                                  'I have read and agree to the Terms and Conditions and Privacy Policy.',
                                  style: GoogleFonts.inter(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(left: 28.0),
                              child: Text(
                                state.errorText ?? '',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 176, 43, 34),
                                    fontSize: 12),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _signUpWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 12),
                    ),
                    child: Text(
                      'SIGN UP',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF517E4C),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signin');
                    },
                    child: Text(
                      'Already have an account? SIGN IN',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool obscureText = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            height: 56.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color.fromARGB(185, 0, 0, 0)),
            ),
            child: DropdownButton<String>(
              value: selectedRegion,
              underline: const SizedBox.shrink(),
              style: GoogleFonts.inter(color: Colors.black, fontSize: 16),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRegion = newValue!;
                });
              },
              items: regions.entries.map<DropdownMenuItem<String>>((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value,
                  child:
                      Text(entry.value, style: GoogleFonts.inter(fontSize: 16)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Phone number',
                hintStyle: GoogleFonts.inter(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              validator: (value) => _validatePhoneNumber(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: GoogleFonts.inter(color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty || value.length < 8) {
            return 'Password must be at least 8 characters long.';
          }
          return null;
        },
      ),
    );
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty || value.length < 3) {
      return 'Username must be at least 3 characters long.';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final fullPhoneNumber = selectedRegion + (value ?? '');
    if (!RegExp(r'^(\+60\d{9,10}|\+62\d{9,12}|\+66\d{9}|\+65\d{8}|\+63\d{10})$')
        .hasMatch(fullPhoneNumber)) {
      return 'Invalid phone number for selected region.';
    }
    return null;
  }
}
