import 'package:flutter/material.dart';
import '../models/application.dart';

class ApplicationsScreen extends StatelessWidget {
  final List<Application> applications = [
    Application(
      jobTitle: 'Research Assistant - AI Lab',
      company: 'Dr. Sarah Johnson',
      appliedDate: '2 days ago',
      status: ApplicationStatus.shortlisted,
    ),
    Application(
      jobTitle: 'Content Writer - Startup',
      company: 'TechEd Solutions',
      appliedDate: '5 days ago',
      status: ApplicationStatus.underReview,
    ),
    Application(
      jobTitle: 'Web Developer - Local Business',
      company: 'Local Shop',
      appliedDate: '1 week ago',
      status: ApplicationStatus.completed,
    ),
    Application(
      jobTitle: 'Event Management Intern',
      company: 'Student Affairs',
      appliedDate: '1 week ago',
      status: ApplicationStatus.applied,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Applications'),
      ),
      body: Column(
        children: [
          // Stats Cards
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatCard('8', 'Active Applications'),
                SizedBox(width: 12),
                _buildStatCard('3', 'Interviews Scheduled'),
              ],
            ),
          ),
          // Applications List
          Expanded(
            child: ListView.builder(
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      application.jobTitle,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(application.company),
                          SizedBox(height: 4),
                          Text(
                            'Applied ${application.appliedDate}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    trailing: _buildStatusBadge(application.status),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Stat Card Widget
  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F46E5),
                ),
              ),
              SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Status Badge Widget
  Widget _buildStatusBadge(ApplicationStatus status) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);
    final icon = _getStatusIcon(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return Colors.orange;
      case ApplicationStatus.underReview:
        return Colors.blue;
      case ApplicationStatus.shortlisted:
        return Colors.purple;
      case ApplicationStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return Icons.send;
      case ApplicationStatus.underReview:
        return Icons.search;
      case ApplicationStatus.shortlisted:
        return Icons.star;
      case ApplicationStatus.completed:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.completed:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }
}
//