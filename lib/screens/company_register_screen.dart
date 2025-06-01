import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../screens/auth_screen.dart';
import '../screens/company_dashboard_screen.dart';

final firestoreService = FirestoreService();

class CompanyRegisterScreen extends StatefulWidget {
  const CompanyRegisterScreen({super.key});

  @override
  State<CompanyRegisterScreen> createState() => _CompanyRegisterScreenState();
}

class _CompanyRegisterScreenState extends State<CompanyRegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _checkingStatusOnInit = true;

  @override
  void initState() {
    super.initState();
    _checkApprovalOnInit();
  }

  Future<void> _checkApprovalOnInit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _checkingStatusOnInit = false;
      });
      return;
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      setState(() {
        _checkingStatusOnInit = false;
      });
      return;
    }

    final status = await firestoreService.getCompanyStatusByEmail(email);

    if (status == 'approved') {
      if (!mounted) return;
      // Auto redirect without message on subsequent loads
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CompanyDashboardScreen(
            email: email,
            // Removed showCongratsMessage here
          ),
        ),
      );
    } else {
      // Show the form with email prefilled
      emailController.text = email;
      setState(() {
        _checkingStatusOnInit = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void registerCompany() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await firestoreService.addPendingCompany({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'status': 'pending',
        'submittedAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company request submitted!')),
      );

      nameController.clear();
      // Keep emailController.text for checking status
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: $e')),
      );
    }
  }

  void checkCompanyStatus() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email to check status')),
      );
      return;
    }

    final status = await firestoreService.getCompanyStatusByEmail(email);

    if (status == 'approved') {
      // Directly navigate to dashboard without showing snackbar here
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CompanyDashboardScreen(
            email: email,
            // Removed showCongratsMessage here
          ),
        ),
      );
    } else {
      // Show appropriate messages for pending or no request
      String message;
      if (status == null) {
        message = 'No request found for this email.';
      } else if (status == 'pending') {
        message = 'Your request is still pending approval.';
      } else {
        message = 'Status: $status';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple;

    if (_checkingStatusOnInit) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Company Register'),
          backgroundColor: primaryColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: logout,
            ),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Register'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Icon(Icons.business_center_rounded, size: 80, color: primaryColor),
              const SizedBox(height: 24),
              const Text(
                'Submit your company registration request for approval.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              _buildTextField(
                controller: nameController,
                label: 'Company Name',
                icon: Icons.apartment,
                validator: (val) =>
                val == null || val.isEmpty ? 'Please enter company name' : null,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: emailController,
                label: 'Contact Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter your email';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(val)) return 'Enter a valid email';
                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Request'),
                  onPressed: registerCompany,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Check Request Status'),
                  onPressed: checkCompanyStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.shade50,
                    foregroundColor: primaryColor.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
//