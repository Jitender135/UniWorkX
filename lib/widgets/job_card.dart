import 'package:flutter/material.dart';
import '../models/job.dart';

class JobCard extends StatefulWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({required this.job, required this.onTap, Key? key}) : super(key: key);

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: widget.job.isUrgent
                        ? Color(0xFFEF4444).withOpacity(0.2)
                        : Colors.grey.shade100,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Gradient overlay for urgent jobs
                      if (widget.job.isUrgent)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Color(0xFFEF4444).withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                stops: [0.0, 1.0],
                              ),
                            ),
                          ),
                        ),

                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Company logo placeholder
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF2563EB),
                                        Color(0xFF3B82F6),
                                        Color(0xFF60A5FA),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF2563EB).withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.job.company.isNotEmpty
                                          ? widget.job.company[0].toUpperCase()
                                          : 'C',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 14),

                                // Job info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title and urgent badge
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.job.title,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                                letterSpacing: -0.2,
                                                height: 1.2,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (widget.job.isUrgent) ...[
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0xFFEF4444).withOpacity(0.3),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.local_fire_department_rounded,
                                                    size: 10,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 3),
                                                  Text(
                                                    'URGENT',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      SizedBox(height: 6),

                                      // Company name
                                      Text(
                                        widget.job.company,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF2563EB),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Action indicator
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2563EB).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            // Description
                            Text(
                              widget.job.description,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 16),

                            // Meta information chips
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEnhancedMetaChip(
                                    Icons.payments_outlined,
                                    widget.job.pay,
                                    Color(0xFF10B981),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildEnhancedMetaChip(
                                    Icons.location_on_outlined,
                                    widget.job.location,
                                    Color(0xFF8B5CF6),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildEnhancedMetaChip(
                                    Icons.access_time_outlined,
                                    widget.job.duration,
                                    Color(0xFFF59E0B),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _buildEnhancedMetaChip(
                                    Icons.work_outline_rounded,
                                    widget.job.category,
                                    Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            // Tags section
                            if (widget.job.tags.isNotEmpty) ...[
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: widget.job.tags.take(4).map((tag) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 16),
                            ],

                            // Bottom section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Posted time (you can add this to your Job model)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule_outlined,
                                      size: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Posted recently', // You can make this dynamic
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                // Apply button
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF2563EB).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'View Details',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 14,
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedMetaChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
