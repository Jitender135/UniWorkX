import 'package:flutter/material.dart';
import '../models/job.dart';
import 'messages_screen.dart';
import 'job_application_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({required this.job, Key? key}) : super(key: key);

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool isBookmarked = false;
  bool showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    // Get the bottom padding to account for safe area and navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = 70.0 + bottomPadding; // Reduced estimated height

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Compact App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1E293B),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF1D4ED8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 40, 20, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50, // Reduced from 60
                          height: 50, // Reduced from 60
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12), // Reduced from 16
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10, // Reduced from 15
                                offset: Offset(0, 3), // Reduced from 5
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.business_center_rounded,
                            color: Color(0xFF2563EB),
                            size: 24, // Reduced from 30
                          ),
                        ),
                        SizedBox(height: 8), // Reduced from 12
                        Text(
                          widget.job.title,
                          style: TextStyle(
                            fontSize: 20, // Reduced from 22
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4), // Reduced from 6
                        Text(
                          widget.job.company,
                          style: TextStyle(
                            fontSize: 14, // Reduced from 16
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6), // Reduced from 8
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Reduced padding
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16), // Reduced from 20
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 12, // Reduced from 14
                                color: Colors.white,
                              ),
                              SizedBox(width: 3), // Reduced from 4
                              Text(
                                widget.job.location,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11, // Reduced from 12
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isBookmarked = !isBookmarked;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isBookmarked ? 'Job bookmarked!' : 'Bookmark removed'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color(0xFF2563EB),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () => _showShareBottomSheet(context),
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Key Statistics Cards - Only Salary and Duration
                Container(
                  margin: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(child: _buildStatCard(Icons.payments_rounded, 'Salary', widget.job.pay, Color(0xFF059669))),
                      SizedBox(width: 12),
                      Expanded(child: _buildStatCard(Icons.schedule_rounded, 'Duration', widget.job.duration, Color(0xFF7C3AED))),
                    ],
                  ),
                ),

                SizedBox(height: 4), // Reduced spacing

                // Quick Actions
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          Icons.chat_bubble_rounded,
                          'Message',
                          Color(0xFF2563EB),
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MessagesScreen()),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          Icons.phone_rounded,
                          'Contact',
                          Color(0xFF059669),
                              () => _showContactOptions(context),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          Icons.business_rounded,
                          'Company',
                          Color(0xFF7C3AED),
                              () => _showCompanyInfo(context),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Job Description - White Background
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF2563EB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.description_rounded,
                                color: Color(0xFF2563EB),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Job Description',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        AnimatedCrossFade(
                          duration: Duration(milliseconds: 300),
                          crossFadeState: showFullDescription
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Text(
                            widget.job.description.length > 150
                                ? '${widget.job.description.substring(0, 150)}...'
                                : widget.job.description,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.7,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          secondChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.7,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(height: 24),
                              _buildSectionHeader('Key Responsibilities', Icons.checklist_rounded),
                              SizedBox(height: 16),
                              ..._buildBulletPoints([
                                'Collaborate with cross-functional teams to deliver high-quality solutions',
                                'Participate in code reviews and maintain coding standards',
                                'Implement new features and optimize existing functionality',
                                'Document technical specifications and processes',
                              ]),
                              SizedBox(height: 24),
                              _buildSectionHeader('Requirements', Icons.task_alt_rounded),
                              SizedBox(height: 16),
                              ..._buildBulletPoints([
                                'Bachelor\'s degree in Computer Science or related field',
                                'Strong problem-solving and analytical skills',
                                'Excellent communication and teamwork abilities',
                                'Passion for learning new technologies',
                              ]),
                            ],
                          ),
                        ),
                        if (widget.job.description.length > 150)
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  showFullDescription = !showFullDescription;
                                });
                              },
                              icon: Icon(
                                showFullDescription ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                                color: Color(0xFF2563EB),
                              ),
                              label: Text(
                                showFullDescription ? 'Show Less' : 'Read More',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Required Skills - White Background
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF2563EB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.star_rounded,
                                color: Color(0xFF2563EB),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Required Skills',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: widget.job.tags.map((tag) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF2563EB).withOpacity(0.1),
                                  Color(0xFF1D4ED8).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Color(0xFF2563EB).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom spacing that accounts for the bottom navigation bar
                SizedBox(height: bottomNavHeight + 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MessagesScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF2563EB), width: 2),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(Icons.chat_bubble_rounded, color: Color(0xFF2563EB), size: 18),
                  label: Text(
                    'Message',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobApplicationScreen(job: widget.job),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    'Apply Now',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: Offset(0, 4),
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
            child: Icon(icon, size: 24, color: color),
          ),
          SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF2563EB), size: 20),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBulletPoints(List<String> points) {
    return points.map((point) => Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              point,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Share Job',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.link_rounded, 'Copy Link', Color(0xFF2563EB)),
                _buildShareOption(Icons.message_rounded, 'Message', Color(0xFF059669)),
                _buildShareOption(Icons.email_rounded, 'Email', Color(0xFFEF4444)),
                _buildShareOption(Icons.more_horiz_rounded, 'More', Color(0xFF7C3AED)),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Contact Employer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'Choose how you would like to contact the employer.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Call',
              style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Email'),
          ),
        ],
      ),
    );
  }

  void _showCompanyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          widget.job.company,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About the Company',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'A leading technology company focused on innovation, growth, and creating exceptional user experiences.',
              style: TextStyle(
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}