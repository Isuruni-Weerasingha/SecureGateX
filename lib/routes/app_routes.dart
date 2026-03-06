import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/authentication_selection_screen.dart';
import '../screens/fingerprint_settings_screen.dart';
import '../screens/home_screen.dart';
import '../screens/qr_code_scan_screen.dart';
import '../screens/activity_log_screen.dart';
import '../screens/guest_access_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/smart_contract_status_screen.dart';
import '../screens/about_screen.dart';
import '../screens/help_screen.dart';

/// Central route configuration for the app
/// Defines all named routes and their corresponding screens
class AppRoutes {
  // Route names as constants
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String authSelection = 'auth-selection';
  static const String fingerprintSettings = 'fingerprint-settings';
  static const String home = 'home';
  static const String qrScan = 'qr-scan';
  static const String activityLog = 'activity-log';
  static const String guestAccess = 'guest-access';
  static const String notifications = 'notifications';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String smartContract = 'smart-contract';
  static const String about = 'about';
  static const String help = 'help';

  /// Get all routes for MaterialApp
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => SplashScreen(
            onComplete: () {
              Navigator.of(context).pushReplacementNamed(login);
            },
          ),
      login: (context) => LoginScreen(
            onLogin: (userName) {
              // After successful login, navigate to auth-selection
              Navigator.of(context).pushReplacementNamed(authSelection);
            },
          ),
      register: (context) => const RegisterScreen(),
      authSelection: (context) => AuthenticationSelectionScreen(
            onNavigate: (screen) {
              Navigator.of(context).pushNamed(screen);
            },
            onBack: () => Navigator.of(context).pop(),
          ),
      fingerprintSettings: (context) => FingerprintSettingsScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
      home: (context) {
        return HomeScreen(
          userName: 'User',
          onNavigate: (screen) {
            Navigator.of(context).pushNamed(screen);
          },
        );
      },
      qrScan: (context) => QRCodeScanScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
      activityLog: (context) => ActivityLogScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
      guestAccess: (context) => GuestAccessScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
      notifications: (context) => NotificationsScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
      profile: (context) {
        return ProfileScreen(
          userName: 'User',
          onNavigate: (screen) {
            Navigator.of(context).pushNamed(screen);
          },
          onBack: () => Navigator.of(context).pop(),
        );
      },
      settings: (context) => SettingsScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
      smartContract: (context) => SmartContractStatusScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
      about: (context) => AboutScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
      help: (context) => HelpScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
    };
  }
}

