import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uni_work_x_01/screens/Admin_dashboard.dart';
import 'package:uni_work_x_01/screens/company_dashboard_screen.dart';

import 'main_screen.dart';
import 'company_register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Color scheme
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color darkBlue = Color(0xFF1E40AF);
  static const Color backgroundGray = Color(0xFFF8FAFC);
  static const Color cardWhite = Color(0xFFFFFFFF);

  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  bool _loginShowPassword = false;
  bool _signupShowPassword = false;
  bool _signupShowConfirmPassword = false;
  bool _isLoginLoading = false;
  bool _isSignupLoading = false;

  String? _loginRole;
  String? _signupRole;

  final List<String> _roles = ['Student', 'Company HR', 'Admin'];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  bool isValidUniversityEmail(String email) {
    final pattern = r'^[a-z]+\.[a-z]+\.\d{2}(cse|ecs|me)@bmu\.edu\.in$';
    final regex = RegExp(pattern);
    return regex.hasMatch(email.toLowerCase());
  }

  bool isValidCompanyEmail(String email) {
    final pattern = r'^[^@]+@[^@]+\.[^@]+$';
    final regex = RegExp(pattern);
    return regex.hasMatch(email.toLowerCase());
  }

  String? validateSignupEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (_signupRole == null) return 'Please select a role first';

    if (_signupRole == 'Student') {
      if (!isValidUniversityEmail(value)) return 'Enter a valid university email';
    } else if (_signupRole == 'Company HR') {
      if (!isValidCompanyEmail(value)) return 'Enter a valid company email';
    } else if (_signupRole == 'Admin') {
      return 'Admin signup is not allowed';
    }
    return null;
  }

  String? validateLoginEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (_loginRole == null) return 'Please select a role first';

    if (_loginRole == 'Student') {
      if (!isValidUniversityEmail(value)) return 'Enter a valid university email';
    } else if (_loginRole == 'Company HR') {
      if (!isValidCompanyEmail(value)) return 'Enter a valid company email';
    } else if (_loginRole == 'Admin') {
      if (value != 'jitendersingh95265@gmail.com') return 'Invalid admin email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWide = screenWidth > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundGray,
              Color(0xFFE0E7FF),
              Color(0xFFF0F4FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : 24,
                vertical: 32,
              ),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isWide ? 480 : screenWidth,
                          minHeight: screenHeight > 800 ? 600 : screenHeight * 0.7,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardWhite,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withOpacity(0.1),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 40),
                                _buildTabSection(),
                                const SizedBox(height: 32),
                                _buildTabContent(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryBlue, lightBlue],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset(
              'assets/images/UniWorkX_logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [primaryBlue, lightBlue],
          ).createShader(bounds),
          child: const Text(
            'UniWorkX',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connect • Learn • Grow',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(27),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(23),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: primaryBlue,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login_rounded, size: 20),
                SizedBox(width: 8),
                Text('Login'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_rounded, size: 20),
                SizedBox(width: 8),
                Text('Sign Up'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 480,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginForm(),
          _buildSignupForm(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildRoleDropdown(
              value: _loginRole,
              onChanged: (val) => setState(() => _loginRole = val),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _loginEmailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: validateLoginEmail,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _loginPasswordController,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: !_loginShowPassword,
              validator: (val) =>
              val == null || val.isEmpty ? 'Please enter your password' : null,
              suffixIcon: IconButton(
                icon: Icon(
                  _loginShowPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.grey[600],
                ),
                onPressed: () => setState(() => _loginShowPassword = !_loginShowPassword),
              ),
            ),
            const SizedBox(height: 32),
            _buildPrimaryButton(
              text: 'Login',
              isLoading: _isLoginLoading,
              onPressed: _login,
              icon: Icons.login_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildRoleDropdown(
              value: _signupRole,
              onChanged: (val) => setState(() => _signupRole = val),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _signupNameController,
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              validator: (val) =>
              val == null || val.isEmpty ? 'Please enter your full name' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _signupEmailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: validateSignupEmail,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _signupPasswordController,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: !_signupShowPassword,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter password';
                }
                if (val.length < 6) {
                  return 'Password should be at least 6 characters';
                }
                return null;
              },
              suffixIcon: IconButton(
                icon: Icon(
                  _signupShowPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.grey[600],
                ),
                onPressed: () => setState(() => _signupShowPassword = !_signupShowPassword),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _signupConfirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline_rounded,
              obscureText: !_signupShowConfirmPassword,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Please confirm your password';
                if (val != _signupPasswordController.text) return 'Passwords do not match';
                return null;
              },
              suffixIcon: IconButton(
                icon: Icon(
                  _signupShowConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.grey[600],
                ),
                onPressed: () => setState(() => _signupShowConfirmPassword = !_signupShowConfirmPassword),
              ),
            ),
            const SizedBox(height: 32),
            _buildPrimaryButton(
              text: 'Create Account',
              isLoading: _isSignupLoading,
              onPressed: _signup,
              icon: Icons.person_add_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDropdown({required String? value, required void Function(String?) onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: 'Select Your Role',
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.person_search_rounded,
            color: primaryBlue,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        dropdownColor: cardWhite,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryBlue),
        items: _roles
            .map((role) => DropdownMenuItem(
          value: role,
          child: Text(
            role,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ))
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null || val.isEmpty ? 'Please select a role' : null,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: primaryBlue,
            size: 22,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, lightBlue],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: cardWhite,
            strokeWidth: 2.5,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: cardWhite,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: cardWhite,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoginLoading = true);

    try {
      final email = _loginEmailController.text.trim();
      final password = _loginPasswordController.text.trim();

      if (_loginRole == 'Admin') {
        if (email == 'jitendersingh95265@gmail.com' && password == '1354') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PendingCompaniesScreen()),
          );
        } else {
          _showError('Invalid admin credentials.');
        }
        return;
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User data not found. Please sign up first.',
        );
      }

      final userData = doc.data()!;
      final role = userData['role'] as String?;
      final approved = userData['approved'] as bool? ?? false;

      if (role == null || role != _loginRole) {
        _showError('Role mismatch. Please check your selected role.');
        await _auth.signOut();
      } else if (role == 'Student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else if (role == 'Company HR') {
        if (approved) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CompanyDashboardScreen(email: email)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CompanyRegisterScreen()),
          );
        }
      } else {
        _showError('Unknown user role.');
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Authentication failed.');
    } catch (e) {
      _showError('An error occurred. Please try again.');
    } finally {
      setState(() => _isLoginLoading = false);
    }
  }

  Future<void> _signup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    if (_signupRole == null) {
      _showError('Please select a role');
      return;
    }

    setState(() => _isSignupLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // Create user document in Firestore
      await _firestore.collection('users').doc(uid).set({
        'fullName': _signupNameController.text.trim(),
        'email': _signupEmailController.text.trim(),
        'role': _signupRole,
        'approved': _signupRole == 'Company HR' ? false : true, // Students auto approved
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (_signupRole == 'Student') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CompanyRegisterScreen()));
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Signup failed.');
    } catch (e) {
      _showError('An error occurred. Please try again.');
    } finally {
      setState(() => _isSignupLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: cardWhite),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: cardWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}