import 'package:flutter/material.dart';

class DoorControlScreen extends StatefulWidget {
  const DoorControlScreen({super.key});

  @override
  State<DoorControlScreen> createState() => _DoorControlScreenState();
}

class _DoorControlScreenState extends State<DoorControlScreen> {
  bool _isLocked = true;
  bool _isProcessing = false;

  Future<void> _toggleDoor() async {
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLocked = !_isLocked;
      _isProcessing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLocked ? 'Door Locked' : 'Door Unlocked'),
          backgroundColor: _isLocked ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2F),
        title: const Text(
          'Door Control',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildDoorStatusCard(),
              const SizedBox(height: 40),
              _buildControlButton(),
              const SizedBox(height: 40),
              _buildDoorList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoorStatusCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isLocked
              ? [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.1)]
              : [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _isLocked ? Colors.red : Colors.green,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isLocked ? Colors.red : Colors.green).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (_isLocked ? Colors.red : Colors.green).withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: (_isLocked ? Colors.red : Colors.green).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              _isLocked ? Icons.lock : Icons.lock_open,
              size: 60,
              color: _isLocked ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isLocked ? 'LOCKED' : 'UNLOCKED',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _isLocked ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Main Entrance',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C2FF).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _toggleDoor,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C2FF),
          disabledBackgroundColor: const Color(0xFF00C2FF).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isLocked ? 'UNLOCK DOOR' : 'LOCK DOOR',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildDoorList() {
    final doors = [
      {'name': 'Main Entrance', 'status': 'Unlocked', 'color': Colors.green},
      {'name': 'Back Door', 'status': 'Locked', 'color': Colors.red},
      {'name': 'Garage Door', 'status': 'Locked', 'color': Colors.red},
      {'name': 'Side Gate', 'status': 'Unlocked', 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Doors',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        ...doors.map((door) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (door['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        door['status'] == 'Locked' ? Icons.lock : Icons.lock_open,
                        color: door['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            door['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: door['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                door['status'] as String,
                                style: TextStyle(
                                  color: door['color'] as Color,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white70),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

