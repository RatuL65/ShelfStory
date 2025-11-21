import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/book_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/google_signin_screen.dart'; // Changed from phone_auth_screen
import 'utils/constants.dart';
import 'models/book.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first
  await Firebase.initializeApp();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Book adapter
  Hive.registerAdapter(BookAdapter());
  
  // Open boxes with proper types
  await Hive.openBox<Book>('books');
  await Hive.openBox('user');
  await Hive.openBox('settings');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyAppWithTheme(),
    );
  }
}

class MyAppWithTheme extends StatelessWidget {
  const MyAppWithTheme({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'ShelfStory',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Light Theme
      theme: ThemeData(
        primaryColor: AppColors.primaryBrown,
        scaffoldBackgroundColor: AppColors.backgroundCream,
        fontFamily: GoogleFonts.merriweather().fontFamily,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBrown,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkBrown,
          foregroundColor: AppColors.cream,
          elevation: 0,
        ),
        cardColor: AppColors.cream,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGold,
            foregroundColor: AppColors.darkBrown,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      
      // Dark Theme
      darkTheme: ThemeData(
        primaryColor: AppColors.darkPrimary,
        scaffoldBackgroundColor: AppColors.darkBackground,
        fontFamily: GoogleFonts.merriweather().fontFamily,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.darkPrimary,
          brightness: Brightness.dark,
          background: AppColors.darkBackground,
          surface: AppColors.darkSurface,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkText,
          elevation: 0,
        ),
        cardColor: AppColors.darkSurface,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPrimary,
            foregroundColor: AppColors.darkBackground,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      
      home: const SplashScreen(),
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
    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Check if user is authenticated with Firebase
      final User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        // User is authenticated - load data and go to home
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUser();

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // No Firebase user - go to Google sign-in screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GoogleSignInScreen()),
        );
      }
    } catch (e) {
      print('Error during initialization: $e');
      if (!mounted) return;
      // On error, go to Google sign-in screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GoogleSignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.darkBrown,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories,
              size: 100,
              color: AppColors.accentGold,
            ),
            const SizedBox(height: 24),
            Text(
              'ShelfStory',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Personal Library',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.cream,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              color: AppColors.accentGold,
            ),
          ],
        ),
      ),
    );
  }
}
