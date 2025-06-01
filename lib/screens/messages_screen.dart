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
      appBar: AppBar(
        title: Text('Messages'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search Messages',
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: messages.length,
        separatorBuilder: (context, index) => Divider(height: 1),
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

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Color(0xFF4F46E5),
          child: Text(
            initials,
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: unread ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
            color: Colors.grey.shade700,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (unread) ...[
              SizedBox(height: 6),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color(0xFF4F46E5),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
//