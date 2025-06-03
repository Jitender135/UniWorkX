import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';  // Replace with your actual Auth/Login screen file

// Define consistent color palette
class AppColors {
  static const Color primary = Color(0xFF3B82F6);      // #3B82F6
  static const Color primaryDark = Color(0xFF1E40AF);   // #1E40AF
  static const Color primaryLight = Color(0xFFDBEAFE);  // Light blue for backgrounds
  static const Color primaryUltraLight = Color(0xFFF0F7FF); // Ultra light blue
}

class CompanyDashboardScreen extends StatefulWidget {
  final String email;
  final bool showCongratsMessage;

  const CompanyDashboardScreen({
    super.key,
    required this.email,
    this.showCongratsMessage = false,
  });

  @override
  _CompanyDashboardScreenState createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;

  // Add loading state
  bool _isLoading = true;

  // Add animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Sample data - replace with your actual data
  final List<Map<String, dynamic>> _jobPosts = [
    {
      'title': 'Flutter Developer Intern',
      'category': 'Internship',
      'applications': 24,
      'deadline': DateTime.now().add(Duration(days: 15)),
      'status': 'Active',
      'location': 'Remote',
      'pay': '₹20,000/month'
    },
    {
      'title': 'UI/UX Designer',
      'category': 'Part-time',
      'applications': 12,
      'deadline': DateTime.now().add(Duration(days: 8)),
      'status': 'Active',
      'location': 'On-campus',
      'pay': '₹15,000/month'
    },
    {
      'title': 'Data Analyst',
      'category': 'Research',
      'applications': 18,
      'deadline': DateTime.now().add(Duration(days: 22)),
      'status': 'Draft',
      'location': 'Hybrid',
      'pay': '₹25,000/month'
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Simulate data loading and start animation
    _initializeData();
  }

  void _initializeData() async {
    // Simulate loading delay (remove this in production)
    await Future.delayed(Duration(milliseconds: 100));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => AuthScreen()),
            (route) => false,
      );
    }
  }

  void _showAddJobModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddJobScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initializing
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Hero(
                  tag: 'company_logo',
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.business, color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'HR Dashboard',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis, // Add this
                      ),
                      Text(
                        widget.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1, // Add this
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications_outlined, color: Colors.grey[700]),
              ),
              PopupMenuButton(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, size: 18, color: AppColors.primary),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.settings_outlined),
                      title: Text('Settings'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.help_outline),
                      title: Text('Help'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    onTap: _logout,
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('Logout', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8),
            ],
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboardView(),
            _buildJobsView(),
            _buildApplicationsView(),
            _buildAnalyticsView(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (mounted) {
                setState(() => _selectedIndex = index);
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey[600],
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outline),
                activeIcon: Icon(Icons.work),
                label: 'Jobs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Applications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddJobModal,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: Icon(Icons.add),
          label: Text('Add Job'),
          elevation: 4,
          heroTag: "add_job_fab", // Add unique hero tag
        ),
      ),
    );
  }

  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      physics: BouncingScrollPhysics(), // Smooth scrolling
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards with staggered animation
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            child: Row(
              children: [
                Expanded(child: _buildStatsCard('Active Jobs', '8', Icons.work, AppColors.primary)),
                SizedBox(width: 12),
                Expanded(child: _buildStatsCard('Applications', '156', Icons.people, Colors.green)),
              ],
            ),
          ),
          SizedBox(height: 12),
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            child: Row(
              children: [
                Expanded(child: _buildStatsCard('Interviews', '24', Icons.video_call, Colors.orange)),
                SizedBox(width: 12),
                Expanded(child: _buildStatsCard('Hired', '12', Icons.check_circle, Colors.purple)),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Recent Activity
          _buildSectionHeader('Recent Activity'),
          SizedBox(height: 12),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            child: _buildActivityCard(),
          ),

          SizedBox(height: 24),

          // Quick Actions
          _buildSectionHeader('Quick Actions'),
          SizedBox(height: 12),
          AnimatedContainer(
            duration: Duration(milliseconds: 600),
            child: _buildQuickActions(),
          ),

          // Add some bottom padding for FAB
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildJobsView() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search jobs...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    isDense: true, // Add this to reduce height
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.filter_list),
                  constraints: BoxConstraints.tightFor(width: 40, height: 40), // Constrain size
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            physics: BouncingScrollPhysics(),
            itemCount: _jobPosts.length,
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                child: _buildJobCard(_jobPosts[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Applications View',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Manage job applications here',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Analytics View',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'View hiring metrics and reports',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(Icons.trending_up, color: Colors.green, size: 16),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text('View All', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildActivityCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActivityItem(
            'New application received',
            'Flutter Developer position',
            '2 min ago',
            Icons.person_add,
            Colors.green,
          ),
          Divider(height: 24),
          _buildActivityItem(
            'Interview scheduled',
            'UI/UX Designer role',
            '1 hour ago',
            Icons.calendar_today,
            AppColors.primary,
          ),
          Divider(height: 24),
          _buildActivityItem(
            'Job post published',
            'Data Analyst position',
            '3 hours ago',
            Icons.work,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
        Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            'Post Job',
            Icons.add_circle_outline,
            AppColors.primary,
            _showAddJobModal,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            'View Reports',
            Icons.assessment_outlined,
            Colors.green,
                () {},
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            'Manage Team',
            Icons.group_outlined,
            Colors.purple,
                () {},
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3, // Give more space to title
                child: Text(
                  job['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 8), // Add spacing
              Flexible( // Change from Container to Flexible
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: job['status'] == 'Active' ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job['status'],
                    style: TextStyle(
                      color: job['status'] == 'Active' ? Colors.green[700] : Colors.orange[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(), // Add smooth scrolling
            child: Row(
              children: [
                _buildJobInfoChip(job['category'], Icons.category_outlined),
                SizedBox(width: 8),
                _buildJobInfoChip(job['location'], Icons.location_on_outlined),
                SizedBox(width: 8),
                _buildJobInfoChip(job['pay'], Icons.attach_money),
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${job['applications']} applications',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Deadline: ${DateFormat('dd MMM').format(job['deadline'])}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfoChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          SizedBox(width: 2),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 80), // Limit width
            child: Text(
              text,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  }

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  _AddJobScreenState createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _payController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _benefitsController = TextEditingController();

  String _category = 'Part-time';
  String _location = 'On-campus';
  String _duration = '1 month';
  String _experienceLevel = 'Entry Level';
  DateTime? _applicationDeadline;

  // Enhanced options
  bool _sendNotifications = true;
  bool _makeFeatured = false;
  bool _allowDirectApply = true;
  bool _requireCoverLetter = false;
  bool _requirePortfolio = false;

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _payController.dispose();
    _requirementsController.dispose();
    _responsibilitiesController.dispose();
    _benefitsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _applicationDeadline ?? DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _applicationDeadline = picked;
      });
    }
  }

  void _postJob() {
    if (_formKey.currentState!.validate()) {
      if (_applicationDeadline == null) {
        _showSnackBar('Please select application deadline', Colors.red);
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(width: 16),
              Text('Publishing job...'),
            ],
          ),
        ),
      );

      // Simulate API call
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context); // Close loading dialog
        _showSnackBar('Job Posted Successfully! Students can now apply.', Colors.green);
        Navigator.pop(context); // Close add job screen
      });
    }
  }

  void _saveDraft() {
    _showSnackBar('Job saved as draft', Colors.orange);
    Navigator.pop(context);
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: FadeTransition(
          opacity: _slideAnimation,
          child: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Create Job Posting',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: Colors.grey[600]),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton.icon(
          onPressed: _saveDraft,
          icon: Icon(Icons.save_outlined, size: 18, color: AppColors.primary),
          label: Text('Save Draft', style: TextStyle(color: AppColors.primary)),
        ),
        SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressIndicator(),
            SizedBox(height: 24),
            _buildSection('Basic Information', [
              _buildJobTitleField(),
              SizedBox(height: 16),
              _buildJobDescriptionField(),
              SizedBox(height: 16),
              // Category and Experience Level in horizontal layout
              Row(
                children: [
                  Expanded(child: _buildCategoryDropdown()),
                  SizedBox(width: 16),
                  Expanded(child: _buildExperienceLevelDropdown()),
                ],
              ),
            ]),
            SizedBox(height: 24),
            _buildSection('Job Details', [
              // Location and Duration in horizontal layout
              Row(
                children: [
                  Expanded(child: _buildLocationDropdown()),
                  SizedBox(width: 16),
                  Expanded(child: _buildDurationDropdown()),
                ],
              ),
              SizedBox(height: 16),
              _buildPayField(),
              SizedBox(height: 16),
              _buildDeadlineSelector(),
            ]),
            SizedBox(height: 24),
            _buildSection('Requirements & Responsibilities', [
              _buildRequirementsField(),
              SizedBox(height: 16),
              _buildResponsibilitiesField(),
              SizedBox(height: 16),
              _buildBenefitsField(),
            ]),
            SizedBox(height: 24),
            _buildSection('Application Settings', [
              _buildApplicationSettings(),
            ]),
            SizedBox(height: 32),
            _buildActionButtons(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.work, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Job Posting',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Fill in the details to attract the right candidates',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildJobTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Title *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g., Senior Flutter Developer, UI/UX Designer',
            prefixIcon: Icon(Icons.work_outline, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Job title is required' : null,
        ),
      ],
    );
  }

  Widget _buildJobDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Description *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe the role, company culture, and what makes this opportunity unique...',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.description_outlined, color: AppColors.primary),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Job description is required' : null,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        // Option 3: Use Container with specific constraints if not inside Row/Flex
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 32, // Account for padding
          ),
          child: DropdownButtonFormField<String>(
            value: _category,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: ['Part-time', 'Full-time', 'Internship', 'Contract', 'Research', 'Project-based']
                .map((cat) => DropdownMenuItem(
              value: cat,
              child: Text(
                cat,
                overflow: TextOverflow.ellipsis,
              ),
            ))
                .toList(),
            onChanged: (value) => setState(() => _category = value!),
          ),
        )
      ],
    );
  }

  Widget _buildExperienceLevelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience Level',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: _experienceLevel,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.trending_up_outlined, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: ['Entry Level', 'Mid Level', 'Senior Level', 'Any Level']
                .map((level) => DropdownMenuItem(
              value: level,
              child: Text(
                level,
                overflow: TextOverflow.ellipsis,
              ),
            ))
                .toList(),
            onChanged: (value) => setState(() => _experienceLevel = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: _location,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: ['On-campus', 'Off-campus', 'Remote', 'Hybrid', 'Multiple Locations']
                .map((loc) => DropdownMenuItem(
              value: loc,
              child: Text(
                loc,
                overflow: TextOverflow.ellipsis,
              ),
            ))
                .toList(),
            onChanged: (value) => setState(() => _location = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        IntrinsicWidth(
          child: Container(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              value: _duration,
              isExpanded: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.access_time_outlined, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: ['1 month', '2 months', '3 months', '6 months', '1 year', 'Permanent', 'Flexible']
                  .map((dur) => DropdownMenuItem(
                value: dur,
                child: Text(
                  dur,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _duration = value!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compensation *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _payController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'e.g., ₹25,000/month, ₹500/hour, ₹50,000 stipend',
            prefixIcon: Icon(Icons.currency_rupee, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Compensation is required' : null,
        ),
      ],
    );
  }

  Widget _buildDeadlineSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Application Deadline *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDeadline,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _applicationDeadline != null
                        ? DateFormat('EEEE, dd MMM yyyy').format(_applicationDeadline!)
                        : 'Select application deadline',
                    style: TextStyle(
                      fontSize: 16,
                      color: _applicationDeadline != null
                          ? Colors.black87
                          : Colors.grey[500],
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requirements & Qualifications *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _requirementsController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '• Bachelor\'s degree in Computer Science\n• 2+ years experience with Flutter\n• Strong problem-solving skills\n• Team collaboration experience',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.checklist_outlined, color: AppColors.primary),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Requirements are required' : null,
        ),
      ],
    );
  }

  Widget _buildResponsibilitiesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Responsibilities',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _responsibilitiesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '• Develop mobile applications using Flutter\n• Collaborate with design team\n• Participate in code reviews\n• Maintain application performance',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.assignment_outlined, color: AppColors.primary),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefits & Perks',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _benefitsController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '• Flexible working hours\n• Learning and development opportunities\n• Health insurance coverage',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 45),
              child: Icon(Icons.card_giftcard_outlined, color: AppColors.primary),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingsTile(
          'Send notifications to relevant students',
          'Notify students who match the job criteria',
          _sendNotifications,
              (value) => setState(() => _sendNotifications = value),
          Icons.notifications_outlined,
        ),
        SizedBox(height: 12),
        _buildSettingsTile(
          'Make this job featured',
          'Highlight this job posting for better visibility',
          _makeFeatured,
              (value) => setState(() => _makeFeatured = value),
          Icons.star_outline,
        ),
        SizedBox(height: 12),
        _buildSettingsTile(
          'Allow students to apply directly',
          'Enable one-click applications through the platform',
          _allowDirectApply,
              (value) => setState(() => _allowDirectApply = value),
          Icons.touch_app_outlined,
        ),
        SizedBox(height: 12),
        _buildSettingsTile(
          'Require cover letter',
          'Ask applicants to submit a cover letter',
          _requireCoverLetter,
              (value) => setState(() => _requireCoverLetter = value),
          Icons.description_outlined,
        ),
        SizedBox(height: 12),
        _buildSettingsTile(
          'Require portfolio/work samples',
          'Ask applicants to submit their portfolio',
          _requirePortfolio,
              (value) => setState(() => _requirePortfolio = value),
          Icons.folder_outlined,
        ),
      ],
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, bool value, Function(bool) onChanged, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value ? AppColors.primary.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primary.withOpacity(0.2) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? AppColors.primary.withOpacity(0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primary : Colors.grey[600],
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.3),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Preview Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => _showJobPreview(),
            icon: Icon(Icons.visibility_outlined, size: 20),
            label: Text(
              'Preview Job Posting',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 12),
        // Publish Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _postJob,
            icon: Icon(Icons.publish, size: 20, color: Colors.white),
            label: Text(
              'Publish Job Posting',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
          ),
        ),
        SizedBox(height: 8),
        // Additional Info Text
        Text(
          'By publishing, you agree to our Terms of Service and confirm that all information provided is accurate.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            height: 1.3,
          ),
        ),
      ],
    );
  }

  void _showJobPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildJobPreviewSheet(),
    );
  }

  Widget _buildJobPreviewSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
            ),
            child: Row(
              children: [
                Text(
                  'Job Preview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          // Preview Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: _buildPreviewContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Job Header
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _titleController.text.isEmpty ? 'Job Title' : _titleController.text,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPreviewChip(Icons.work_outline, _category, AppColors.primary),
                  _buildPreviewChip(Icons.location_on_outlined, _location, Colors.orange),
                  _buildPreviewChip(Icons.access_time, _duration, Colors.green),
                ],
              ),
              if (_payController.text.isNotEmpty) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.currency_rupee, color: AppColors.primary, size: 20),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _payController.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 20),

        // Job Description
        if (_descriptionController.text.isNotEmpty) ...[
          _buildPreviewSection('Job Description', _descriptionController.text, Icons.description),
          SizedBox(height: 20),
        ],

        // Requirements
        if (_requirementsController.text.isNotEmpty) ...[
          _buildPreviewSection('Requirements', _requirementsController.text, Icons.checklist),
          SizedBox(height: 20),
        ],

        // Responsibilities
        if (_responsibilitiesController.text.isNotEmpty) ...[
          _buildPreviewSection('Responsibilities', _responsibilitiesController.text, Icons.assignment),
          SizedBox(height: 20),
        ],

        // Benefits
        if (_benefitsController.text.isNotEmpty) ...[
          _buildPreviewSection('Benefits', _benefitsController.text, Icons.card_giftcard),
          SizedBox(height: 20),
        ],

        // Application Info
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Application Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              if (_applicationDeadline != null)
                _buildInfoRow('Application Deadline',
                    DateFormat('dd MMM yyyy').format(_applicationDeadline!)),
              _buildInfoRow('Experience Level', _experienceLevel),
              if (_requireCoverLetter)
                _buildInfoRow('Cover Letter', 'Required'),
              if (_requirePortfolio)
                _buildInfoRow('Portfolio', 'Required'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewChip(IconData icon, String label, Color color) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection(String title, String content, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          Text(
            ':  ',
            style: TextStyle(color: Colors.grey[700]),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
