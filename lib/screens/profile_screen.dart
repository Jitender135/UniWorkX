import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const primaryBlue = Color(0xFF3B82F6);
  static const darkBlue = Color(0xFF1E40AF);
  static const lightBlue = Color(0xFFDBEAFE);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text('No user logged in',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    final displayName = user.displayName ?? 'User';
    final email = user.email ?? '';
    final photoUrl = user.photoURL;
    final initials = _getInitials(displayName);

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Profile',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryBlue, darkBlue],
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Edit profile coming soon!'),
                        backgroundColor: primaryBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Enhanced Profile Header
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Profile Avatar with ring
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [primaryBlue, lightBlue],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: primaryBlue,
                                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                                child: photoUrl == null
                                    ? Text(initials,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ))
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(displayName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              )),
                          SizedBox(height: 4),
                          Text(email,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              )),
                          SizedBox(height: 20),
                          // Enhanced Stats Row
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: lightBlue.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildEnhancedStatItem('Jobs Applied', '12', Icons.work_outline),
                                Container(width: 1, height: 40, color: Colors.grey[300]),
                                _buildEnhancedStatItem('Completed', '5', Icons.check_circle_outline),
                                Container(width: 1, height: 40, color: Colors.grey[300]),
                                _buildEnhancedStatItem('Rating', '4.8', Icons.star_outline),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Enhanced Skills Section
                  _buildSectionCard(
                    'Skills & Expertise',
                    Icons.psychology_outlined,
                    Column(
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: ['Python', 'Java', 'React', 'Node.js', 'MongoDB', 'Machine Learning']
                              .map((skill) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryBlue.withOpacity(0.1), lightBlue.withOpacity(0.3)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primaryBlue.withOpacity(0.4)),
                            ),
                            child: Text(skill,
                                style: TextStyle(
                                  color: darkBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                )),
                          ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Enhanced Recent Work
                  _buildSectionCard(
                    'Recent Work',
                    Icons.history_outlined,
                    Column(
                      children: [
                        _buildEnhancedWorkItem('Research Assistant', 'Dr. Sarah Johnson', '3 months', 5.0),
                        Divider(color: Colors.grey[200]),
                        _buildEnhancedWorkItem('Web Developer', 'Local Business', '2 months', 4.8),
                        Divider(color: Colors.grey[200]),
                        _buildEnhancedWorkItem('Content Writer', 'StartupXYZ', '1 month', 4.9),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Enhanced Settings
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingsItem(Icons.notifications_outlined, 'Notifications', () {}),
                        _buildSettingsItem(Icons.security_outlined, 'Privacy & Security', () {}),
                        _buildSettingsItem(Icons.help_outline, 'Help & Support', () {}),
                        _buildSettingsItem(
                          Icons.logout_rounded,
                          'Logout',
                              () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => AuthScreen()),
                                  (route) => false,
                            );
                          },
                          isLogout: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightBlue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: primaryBlue, size: 20),
                ),
                SizedBox(width: 12),
                Text(title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    )),
              ],
            ),
            SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: primaryBlue, size: 24),
        SizedBox(height: 8),
        Text(value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            )),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }

  Widget _buildEnhancedWorkItem(String title, String company, String duration, double rating) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: lightBlue.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.work_outline, color: primaryBlue, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.grey[800],
                    )),
                SizedBox(height: 2),
                Text(company,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    )),
                Text(duration,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(rating.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[700],
                      fontSize: 13,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLogout ? Colors.red.withOpacity(0.1) : lightBlue.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    color: isLogout ? Colors.red : primaryBlue,
                    size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isLogout ? Colors.red : Colors.grey[800],
                    )),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return parts.take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join();
  }
}