import 'package:flutter/material.dart';
import '../models/job.dart';

class JobApplicationScreen extends StatefulWidget {
  final Job job;

  const JobApplicationScreen({required this.job, Key? key}) : super(key: key);

  @override
  _JobApplicationScreenState createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _motivationController = TextEditingController();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _portfolioController = TextEditingController();

  String _availability = 'Weekdays (9 AM - 5 PM)';
  String _experienceLevel = 'Beginner';
  bool _hasPortfolio = false;
  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  int _currentStep = 0;
  final int _totalSteps = 4;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _motivationController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1E293B),
        title: Text(
          'Apply for Position',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: _saveDraft,
              icon: Icon(Icons.save_rounded, size: 18, color: Color(0xFF2563EB)),
              label: Text(
                'Save Draft',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Progress Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step ${_currentStep + 1} of $_totalSteps',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _getStepTitle(),
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    CircularProgressIndicator(
                      value: (_currentStep + 1) / _totalSteps,
                      backgroundColor: Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                      strokeWidth: 3,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Progress Steps Indicator
                Row(
                  children: List.generate(_totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: index <= _currentStep ? Color(0xFF2563EB) : Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildStepContent(),
                ),
              ),
            ),
          ),

          // Bottom Navigation
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Color(0xFF2563EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Previous',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 16),
                Expanded(
                  flex: _currentStep == 0 ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2563EB),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      _currentStep == _totalSteps - 1 ? 'Submit Application' : 'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildSkillsStep();
      case 2:
        return _buildExperienceStep();
      case 3:
        return _buildReviewStep();
      default:
        return Container();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Personal Information',
            icon: Icons.person_outline_rounded,
            child: Column(
              children: [
                _buildTextFormField(
                  controller: _motivationController,
                  label: 'Why are you interested in this position?',
                  hint: 'Tell us what motivates you to apply for this role...',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please share your motivation';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildDropdownField(
                  label: 'Availability',
                  value: _availability,
                  items: [
                    'Weekdays (9 AM - 5 PM)',
                    'Evenings (6 PM - 10 PM)',
                    'Weekends',
                    'Flexible',
                    'Full-time',
                    'Part-time',
                  ],
                  onChanged: (value) => setState(() => _availability = value!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Skills & Expertise',
          icon: Icons.star_outline_rounded,
          child: Column(
            children: [
              _buildTextFormField(
                controller: _skillsController,
                label: 'Relevant Skills',
                hint: 'List your skills separated by commas (e.g., Flutter, Dart, UI/UX)',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please list your relevant skills';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildDropdownField(
                label: 'Experience Level',
                value: _experienceLevel,
                items: ['Beginner', 'Intermediate', 'Advanced', 'Expert'],
                onChanged: (value) => setState(() => _experienceLevel = value!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Experience & Portfolio',
          icon: Icons.work_outline_rounded,
          child: Column(
            children: [
              _buildTextFormField(
                controller: _experienceController,
                label: 'Previous Experience',
                hint: 'Describe your relevant work experience...',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe your experience';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              _buildSwitchTile(
                title: 'I have a portfolio to share',
                subtitle: 'Include links to your work or projects',
                value: _hasPortfolio,
                onChanged: (value) => setState(() => _hasPortfolio = value),
              ),
              if (_hasPortfolio) ...[
                SizedBox(height: 16),
                _buildTextFormField(
                  controller: _portfolioController,
                  label: 'Portfolio URL',
                  hint: 'https://your-portfolio.com',
                  validator: (value) {
                    if (_hasPortfolio && (value == null || value.trim().isEmpty)) {
                      return 'Please provide your portfolio URL';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Review Your Application',
          icon: Icons.preview_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewItem('Position', widget.job.title),
              _buildReviewItem('Company', widget.job.company),
              _buildReviewItem('Availability', _availability),
              _buildReviewItem('Experience Level', _experienceLevel),
              _buildReviewItem('Motivation', _motivationController.text, isLong: true),
              _buildReviewItem('Skills', _skillsController.text, isLong: true),
              _buildReviewItem('Experience', _experienceController.text, isLong: true),
              if (_hasPortfolio)
                _buildReviewItem('Portfolio', _portfolioController.text),
            ],
          ),
        ),
        SizedBox(height: 24),
        _buildSectionCard(
          title: 'Terms & Conditions',
          icon: Icons.gavel_rounded,
          child: _buildCheckboxTile(
            title: 'I agree to the terms and conditions',
            subtitle: 'By submitting this application, you agree to our privacy policy and terms of service.',
            value: _agreedToTerms,
            onChanged: (value) => setState(() => _agreedToTerms = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1E293B).withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Color(0xFF2563EB), size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFF64748B)),
            filled: true,
            fillColor: Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFF2563EB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value, {bool isLong = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 4),
          Text(
            value.isEmpty ? 'Not provided' : value,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
            maxLines: isLong ? null : 2,
            overflow: isLong ? null : TextOverflow.ellipsis,
          ),
          if (label != 'Portfolio') // Don't add divider after last item
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Divider(color: Color(0xFFE2E8F0)),
            ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Personal Information';
      case 1:
        return 'Skills & Expertise';
      case 2:
        return 'Experience & Portfolio';
      case 3:
        return 'Review & Submit';
      default:
        return '';
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _animationController.reset();
        _animationController.forward();
      }
    } else {
      _submitApplication();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        if (_skillsController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please list your relevant skills'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
          return false;
        }
        return true;
      case 2:
        if (_experienceController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please describe your experience'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
          return false;
        }
        if (_hasPortfolio && _portfolioController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please provide your portfolio URL'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
          return false;
        }
        return true;
      case 3:
        if (!_agreedToTerms) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please agree to the terms and conditions'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _submitApplication() async {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
            ),
            SizedBox(width: 12),
            Text('Application Submitted!'),
          ],
        ),
        content: Text(
          'Your application for ${widget.job.title} has been submitted successfully. We\'ll get back to you soon!',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to job details
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.save_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Draft saved successfully!'),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}