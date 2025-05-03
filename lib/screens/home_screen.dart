import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();
      setState(() {
        userDetails = doc.data();
      });
    } catch (e) {
      print('Failed to fetch user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with soft gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE0F7FA),
                  const Color(0xFFB2EBF2),
                  const Color(0xFF80DEEA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Logo and Tagline
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/appLogo.png',
                            height: 80,
                            width: 80,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Stock Genius",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Your one-stop stock tracking app",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF34495E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Greeting Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Hello, ${userDetails?['username'] ?? user?.email ?? 'User'}!",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "What would you like to explore today?",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF34495E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Navigation Cards Section
                  Expanded(
                    child: GridView(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      children: [
                        _buildNavigationCard(
                          title: "Newsfeed",
                          icon: Icons.article_outlined,
                          color: const Color(0xFF4DB6AC),
                          onTap: () => Navigator.pushNamed(context, '/newsfeed'),
                        ),
                        _buildNavigationCard(
                          title: "Watchlist",
                          icon: Icons.favorite_outline,
                          color: const Color(0xFF81C784),
                          onTap: () => Navigator.pushNamed(context, '/watchlist'),
                        ),
                        _buildNavigationCard(
                          title: "Stock Details",
                          icon: Icons.bar_chart_outlined,
                          color: const Color(0xFF64B5F6),
                          onTap: () => Navigator.pushNamed(context, '/stock_details'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Profile Button
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () => _showProfileDetails(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_outline, color: Color(0xFF2C3E50), size: 24),
                    SizedBox(width: 8),
                    Text(
                      "View Profile",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE57373),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, '/');
        },
      ),
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Profile Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Divider(color: Color(0xFFE0E0E0)),
                ListTile(
                  leading: const Icon(Icons.email, color: Color(0xFF16A085)),
                  title: const Text('Email', style: TextStyle(color: Color(0xFF2C3E50))),
                  subtitle: Text(
                    userDetails?['email'] ?? "N/A",
                    style: const TextStyle(color: Color(0xFF34495E)),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFF16A085)),
                  title: const Text('Username', style: TextStyle(color: Color(0xFF2C3E50))),
                  subtitle: Text(
                    userDetails?['username'] ?? "N/A",
                    style: const TextStyle(color: Color(0xFF34495E)),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Color(0xFF16A085)),
                  title: const Text('Phone', style: TextStyle(color: Color(0xFF2C3E50))),
                  subtitle: Text(
                    userDetails?['phone'] ?? "N/A",
                    style: const TextStyle(color: Color(0xFF34495E)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A085),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
