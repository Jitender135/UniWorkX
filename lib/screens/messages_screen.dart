import 'package:flutter/material.dart';
import 'chat_screen.dart'; // Import your full chat screen here

class MessagesScreen extends StatelessWidget {
  final List<_MessageItemData> messages = [
    _MessageItemData(
      name: 'Dr. Sarah Johnson',
      message: 'Perfect! Yes, come to Room 204 in the CS building...',
      time: '2:30 PM',
      unread: true,
    ),
    _MessageItemData(
      name: 'TechEd Solutions',
      message: 'Thank you for your application. We will review...',
      time: 'Yesterday',
      unread: false,
    ),
    _MessageItemData(
      name: 'Student Affairs',
      message: 'Congratulations! You have been selected for...',
      time: '2 days ago',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1E40AF),
        title: Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Color(0xFF1E40AF),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.search_rounded, color: Color(0xFF3B82F6)),
              onPressed: () {},
              tooltip: 'Search Messages',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3B82F6).withOpacity(0.2),
                  Color(0xFF1E40AF).withOpacity(0.2),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header with message count
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  '${messages.where((m) => m.unread).length} new messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${messages.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Messages List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: messages.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = messages[index];
                return _MessageItem(
                  name: item.name,
                  message: item.message,
                  time: item.time,
                  unread: item.unread,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(recipientName: item.name),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageItemData {
  final String name;
  final String message;
  final String time;
  final bool unread;

  _MessageItemData({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
  });
}

class _MessageItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  const _MessageItem({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .take(2)
        .join();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: unread
            ? Border.all(color: Color(0xFF3B82F6).withOpacity(0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: unread
                ? Color(0xFF3B82F6).withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: unread ? 8 : 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: unread
                          ? [Color(0xFF3B82F6), Color(0xFF1E40AF)]
                          : [Color(0xFF94A3B8), Color(0xFF64748B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (unread ? Color(0xFF3B82F6) : Color(0xFF64748B)).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 16,
                                color: unread ? Color(0xFF1E40AF) : Color(0xFF374151),
                              ),
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              color: unread ? Color(0xFF3B82F6) : Color(0xFF9CA3AF),
                              fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                                color: unread ? Color(0xFF4B5563) : Color(0xFF6B7280),
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (unread) ...[
                            SizedBox(width: 8),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF3B82F6).withOpacity(0.4),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
  }
}