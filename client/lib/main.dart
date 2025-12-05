import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/chirp_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'services/firebase_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  try {
    await FirebaseService().initialize(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ChirpViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ],
      child: MaterialApp(
        title: 'Chirper',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1DA1F2), // Twitter blue
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 1,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF1DA1F2),
            foregroundColor: Colors.white,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.checkAuthStatus();

    if (mounted) {
      if (authViewModel.isAuthenticated) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeView()));
      } else {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginView()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flutter_dash,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Chirper',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}