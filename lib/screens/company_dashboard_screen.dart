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
    Key? key,
    required this.email,
    this.showCongratsMessage = false,
  }) : super(key: key);

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
                      ),
                      Text(
                        widget.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  job['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
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
            ],
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
              Text(
                '${job['applications']} applications',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                'Deadline: ${DateFormat('dd MMM').format(job['deadline'])}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
          Text(
            text,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// Add Job Screen (Modal) - Updated with consistent blue colors
class AddJobScreen extends StatefulWidget {
  @override
  _AddJobScreenState createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _payController = TextEditingController();
  final _requirementsController = TextEditingController();

  String _category = 'Part-time';
  String _location = 'On-campus';
  String _duration = '1 month';
  DateTime? _applicationDeadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _payController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _applicationDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job Posted Successfully! Students can now apply.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Add New Job'),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 0,
    actions: [
    TextButton(
    onPressed: () => Navigator.pop(context),
    child: Text('Cancel', style: TextStyle(color: AppColors.primary)),
    ),
    ],
    ),
    body: Form(
    key: _formKey,
    child: SingleChildScrollView(
    padding: EdgeInsets.all(16),
    physics: BouncingScrollPhysics(),
    child: Column(
    children: [
    TextFormField(
    controller: _titleController,
    decoration: InputDecoration(
    labelText: 'Job Title',
    prefixIcon: Icon(Icons.work_outline, color: AppColors.primary),
    hintText: 'e.g., Research Assistant - AI Lab',
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    ),
    validator: (value) => value!.isEmpty ? 'Please enter job title' : null,
    ),
    SizedBox(height: 16),

    DropdownButtonFormField<String>(
    value: _category,
    decoration: InputDecoration(
    labelText: 'Category',
    prefixIcon: Icon(Icons.category, color: AppColors.primary),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    ),
    items: ['Part-time', 'Research', 'Internship', 'Project-based', 'Remote']
        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
        .toList(),
    onChanged: (value) => setState(() => _category = value!),
    ),
    SizedBox(height: 16),

    Row(
    children: [
    Expanded(
    child: DropdownButtonFormField<String>(
    value: _location,
    decoration: InputDecoration(
    labelText: 'Location',
    prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    ),
    items: ['On-campus', 'Remote', 'Hybrid', 'Off-campus']
        .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
        .toList(),
    onChanged: (value) => setState(() => _location = value!),
    ),
    ),
    SizedBox(width: 16),
    Expanded(
    child: DropdownButtonFormField<String>(
    value: _duration,
    decoration: InputDecoration(
    labelText: 'Duration',
    prefixIcon: Icon(Icons.access_time, color: AppColors.primary),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    ),
    items: ['1 month', '2 months', '3 months', '6 months', 'Flexible']
        .map((dur) => DropdownMenuItem(value: dur, child: Text(dur)))
        .toList(),
    onChanged: (value) => setState(() => _duration = value!),
    ),
    ),
    ],
    ),
    SizedBox(height: 16),

    TextFormField(
    controller: _payController,
    decoration: InputDecoration(
    labelText: 'Pay/Compensation',
    prefixIcon: Icon(Icons.attach_money, color: AppColors.primary),
    hintText: 'e.g., ₹15,000/month or ₹500/hour',
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    ),
    validator: (value) => value!.isEmpty ? 'Please enter compensation' : null,
    ),
    SizedBox(height: 16),
      TextFormField(
        controller: _requirementsController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'Requirements & Qualifications',
          prefixIcon: Icon(Icons.list_alt_outlined, color: AppColors.primary),
          hintText: 'List required skills, qualifications, year of study, etc.',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Please enter requirements' : null,
      ),
      SizedBox(height: 16),

      // Application Deadline
      GestureDetector(
        onTap: _pickDeadline,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: AppColors.primary),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application Deadline',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _applicationDeadline != null
                          ? DateFormat('dd MMM yyyy').format(_applicationDeadline!)
                          : 'Select deadline date',
                      style: TextStyle(
                        fontSize: 16,
                        color: _applicationDeadline != null
                            ? Colors.black87
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
      SizedBox(height: 24),

      // Additional Options
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryUltraLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Options',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 12),
            CheckboxListTile(
              value: true,
              onChanged: (value) {},
              title: Text('Send notifications to relevant students',
                  style: TextStyle(fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
            ),
            CheckboxListTile(
              value: false,
              onChanged: (value) {},
              title: Text('Make this job featured',
                  style: TextStyle(fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
            ),
            CheckboxListTile(
              value: true,
              onChanged: (value) {},
              title: Text('Allow students to apply directly',
                  style: TextStyle(fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
      SizedBox(height: 32),

      // Action Buttons
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Save as draft functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Job saved as draft'),
                    backgroundColor: Colors.orange,
                  ),
                );
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save as Draft',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_applicationDeadline == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select application deadline'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  _postJob();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.publish, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Publish Job',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 16),
    ],
    ),
    ),
    ),
    );
  }
}