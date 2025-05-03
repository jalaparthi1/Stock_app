import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stocktracker_app_project2/screens/newsfeed_screen.dart';
import 'package:stocktracker_app_project2/screens/stock_details_screen.dart';
import 'package:stocktracker_app_project2/screens/watchlist_screen.dart';
import 'package:stocktracker_app_project2/screens/login_screen.dart';
import 'package:stocktracker_app_project2/screens/register_screen.dart';
import 'package:stocktracker_app_project2/screens/home_screen.dart';
import 'package:stocktracker_app_project2/screens/StockPriceHistoryScreen.dart'; // <-- imported correct screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const StockTrackerApp());
}

class StockTrackerApp extends StatelessWidget {
  const StockTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF34495E),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A085),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/newsfeed': (context) => const NewsfeedScreen(),
        '/watchlist': (context) => const WatchlistScreen(),
        '/stock_details': (context) => const StockDetailsScreen(),
        '/stock_price_history': (context) =>
            StockComparisonChart(), // <-- fixed route for StockComparisonChart
      },
    );
  }
}
