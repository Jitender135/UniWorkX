import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';
import '../services/firestore_service.dart';
import 'job_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Part-time', 'Research', 'Remote', 'Urgent'];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _applyFilters();
      });
    });

    _loadJobs();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadJobs() {
    _firestoreService.getActiveJobs().listen((snapshot) {
      if (mounted) {
        setState(() {
          _allJobs = snapshot.docs
              .map((doc) => Job.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
          _applyFilters();
          _isLoading = false;
        });
      }
    }, onError: (error) {
      print('Error loading jobs: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _applyFilters() {
    List<Job> filtered = List.from(_allJobs);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((job) =>
      job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))).toList();
    }

    // Apply category filter
    if (selectedFilter != 'All') {
      switch (selectedFilter) {
        case 'Urgent':
          filtered = filtered.where((job) => job.isUrgent).toList();
          break;
        case 'Remote':
          filtered = filtered.where((job) => job.location.toLowerCase().contains('remote')).toList();
          break;
        case 'Research':
          filtered = filtered.where((job) =>
          job.category.toLowerCase().contains('research') ||
              job.tags.any((tag) => tag.toLowerCase().contains('research'))).toList();
          break;
        default:
          filtered = filtered.where((job) => job.category == selectedFilter).toList();
      }
    }

    setState(() {
      _filteredJobs = filtered;
    });
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    return parts.take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join();
  }

  Future<void> _onRefresh() async {
    _loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? '';
    final initials = _getInitials(displayName);
    final firstName = displayName.isNotEmpty ? displayName.split(' ')[0] : 'there';

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              // App Header
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                snap: false,
                elevation: 0,
                backgroundColor: Color(0xFF2563EB),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1E40AF),
                          Color(0xFF2563EB),
                          Color(0xFF3B82F6),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'UniWorkX',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Find your perfect opportunity',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      initials.isNotEmpty ? initials : 'U',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),

                            // Welcome Message
                            Text(
                              'Hi $firstName! 👋',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Ready to discover amazing opportunities?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 20),

                            // Search Bar
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search jobs, skills, companies...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 16,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 24,
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                      : Icon(
                                    Icons.tune_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Filters Section
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverFilterDelegate(
                  minHeight: 114,
                  maxHeight: 114,
                  child: Container(
                    color: Color(0xFFF8FAFF),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        // Stats Cards
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatsCard(
                                  '${_allJobs.length}',
                                  'Jobs',
                                  Icons.work_outline,
                                  Color(0xFF2563EB),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildStatsCard(
                                  '${_allJobs.where((job) => job.isUrgent).length}',
                                  'Urgent',
                                  Icons.priority_high,
                                  Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),

                        // Filter Chips
                        Container(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filters.length,
                            separatorBuilder: (context, index) => SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final filter = filters[index];
                              final isSelected = selectedFilter == filter;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedFilter = filter;
                                    _applyFilters();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                      colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                                    )
                                        : null,
                                    color: isSelected ? null : Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? Color(0xFF2563EB).withOpacity(0.3)
                                            : Colors.black.withOpacity(0.05),
                                        blurRadius: isSelected ? 6 : 3,
                                        offset: Offset(0, isSelected ? 3 : 1),
                                      ),
                                    ],
                                    border: isSelected
                                        ? null
                                        : Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey.shade700,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            color: Color(0xFF2563EB),
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            )
                : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Opportunities',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFF2563EB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${_filteredJobs.length} jobs',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _filteredJobs.isEmpty
                    ? SliverToBoxAdapter(
                  child: Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_off_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No jobs found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters or search terms',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final job = _filteredJobs[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: JobCard(
                          job: job,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailsScreen(job: job),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _filteredJobs.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(String value, String label, IconData icon, Color color) {
    return Container(
      height: 38,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Sliver Delegate for Sticky Filters
class _SliverFilterDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverFilterDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _SliverFilterDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

// Simplified Job Card Widget
class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({
    Key? key,
    required this.job,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.work_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (job.isUrgent)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'URGENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          job.company,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                job.pay,
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF2563EB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 10,
                                    color: Color(0xFF2563EB),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    job.location,
                                    style: TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                job.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: job.tags.take(3).map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Duration: ${job.duration}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}