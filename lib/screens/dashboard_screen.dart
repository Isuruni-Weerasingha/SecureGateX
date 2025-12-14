import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secure_gatex/screens/door_control_screen.dart';
import 'package:secure_gatex/login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2F),
        title: const Text(
          'SecureGateX',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            color: const Color(0xFF1A1F2F),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(
                  user?.email ?? 'User',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(user?.email ?? 'User'),
            const SizedBox(height: 30),
            _buildQuickActions(context),
            const SizedBox(height: 30),
            _buildRecentActivity(),
            const SizedBox(height: 30),
            _buildDoorStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C2FF), Color(0xFF0099CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C2FF).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.lock_open,
                title: 'Unlock Door',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoorControlScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionCard(
                icon: Icons.lock,
                title: 'Lock Door',
                color: Colors.red,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.history,
                title: 'Access Logs',
                color: Colors.blue,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionCard(
                icon: Icons.settings,
                title: 'Settings',
                color: Colors.orange,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2F),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF2A2F3F),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2F),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF2A2F3F),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.lock_open,
                title: 'Door Unlocked',
                subtitle: 'Main Entrance',
                time: '2 minutes ago',
                color: Colors.green,
              ),
              const Divider(color: Color(0xFF2A2F3F), height: 1),
              _buildActivityItem(
                icon: Icons.lock,
                title: 'Door Locked',
                subtitle: 'Main Entrance',
                time: '15 minutes ago',
                color: Colors.red,
              ),
              const Divider(color: Color(0xFF2A2F3F), height: 1),
              _buildActivityItem(
                icon: Icons.person,
                title: 'Access Granted',
                subtitle: 'Front Door',
                time: '1 hour ago',
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFFC7C7C7), fontSize: 12),
      ),
      trailing: Text(
        time,
        style: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 12),
      ),
    );
  }

  Widget _buildDoorStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Door Status',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Container(
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
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_open, color: Colors.green, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Main Entrance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Unlocked',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
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
      ],
    );
  }
}

