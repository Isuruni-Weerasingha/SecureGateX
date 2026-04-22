import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

/// DemoFlow: programmatically navigates through a sequence of routes
/// Useful for quickly previewing all interfaces in order.
class DemoFlow extends StatefulWidget {
  const DemoFlow({super.key});

  @override
  State<DemoFlow> createState() => _DemoFlowState();
}

class _DemoFlowState extends State<DemoFlow> {
  final List<String> _sequence = [
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.home,
    AppRoutes.authSelection,
    AppRoutes.fingerprintSettings,
    AppRoutes.qrScan,
    AppRoutes.activityLog,
    AppRoutes.guestAccess,
    AppRoutes.notifications,
    AppRoutes.profile,
    AppRoutes.settings,
    AppRoutes.smartContract,
    AppRoutes.about,
    AppRoutes.help,
  ];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Start automated navigation after a short delay so UI can build
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSequence());
  }

  Future<void> _runSequence() async {
    // Each screen will be shown for this duration
    const Duration display = Duration(seconds: 2);

    while (_index < _sequence.length) {
      final route = _sequence[_index];

      // Use pushReplacement so demo advances forward cleanly
      if (!mounted) return;
      try {
        Navigator.of(context).pushReplacementNamed(route);
      } catch (_) {
        // If route not found or Navigator not ready, break out
        break;
      }

      await Future.delayed(display);
      _index++;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a simple placeholder while sequence starts
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Demo mode: cycling through screens...'),
          ],
        ),
      ),
    );
  }
}
