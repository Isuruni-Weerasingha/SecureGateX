import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secure_gatex/firebase_options.dart';
import 'package:secure_gatex/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseInitialized = false;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseInitialized = true;
      debugPrint('✅ Firebase initialized successfully');
    } else {
      firebaseInitialized = true;
      debugPrint('✅ Firebase already initialized');
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Firebase initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    firebaseInitialized = false;
  }
  
  runApp(MyApp(firebaseInitialized: firebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;
  
  const MyApp({super.key, this.firebaseInitialized = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SecureGateX',
      theme: ThemeData.dark(),
      home: LoginScreen(firebaseInitialized: firebaseInitialized),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureGateX'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              } catch (e) {
                debugPrint('Logout error: $e');
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${user?.email ?? 'User'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('You are successfully logged in.'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  debugPrint('Logout error: $e');
                }
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
