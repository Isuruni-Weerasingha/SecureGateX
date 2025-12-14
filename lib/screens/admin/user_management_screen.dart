import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2F),
        title: const Text(
          'User Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddUserDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C2FF)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return _buildUserCard(
                context,
                doc.id,
                data['email'] ?? 'Unknown',
                data['createdAt'],
                data['lastLogin'],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    String userId,
    String email,
    dynamic createdAt,
    dynamic lastLogin,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2F),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF2A2F3F),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF00C2FF).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF00C2FF),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'User ID: ${userId.substring(0, 8)}...',
                  style: const TextStyle(
                    color: Color(0xFF6B6B6B),
                    fontSize: 12,
                  ),
                ),
                if (lastLogin != null)
                  Text(
                    'Last login: ${_formatTimestamp(lastLogin)}',
                    style: const TextStyle(
                      color: Color(0xFF6B6B6B),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: const Color(0xFF1A1F2F),
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Never';
    try {
      final date = (timestamp as Timestamp).toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2F),
        title: const Text(
          'Add New User',
          style: TextStyle(color: Colors.white),
        ),
        content: const TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00C2FF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFF00C2FF))),
          ),
        ],
      ),
    );
  }
}

