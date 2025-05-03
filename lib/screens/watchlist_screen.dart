import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stock_details_screen.dart'; // Import StockDetailsScreen

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _watchlist = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWatchlist();
  }

  Future<void> _fetchWatchlist() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final snapshot = await _firestore
            .collection('watchlists')
            .doc(userId)
            .collection('stocks')
            .get();

        setState(() {
          _watchlist = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching watchlist: $e'),
          backgroundColor: const Color(0xFFE57373),
        ),
      );
    }
  }

  Future<void> _removeStock(String id) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore
            .collection('watchlists')
            .doc(userId)
            .collection('stocks')
            .doc(id)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock removed from watchlist'),
            backgroundColor: Color(0xFF81C784),
          ),
        );

        _fetchWatchlist();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing stock: $e'),
          backgroundColor: const Color(0xFFE57373),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Watchlist',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16A085)),
                  ),
                )
              : _watchlist.isEmpty
                  ? Center(
                      child: Container(
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
                        child: const Text(
                          'Your watchlist is empty.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _watchlist.length,
                      itemBuilder: (context, index) {
                        final stock = _watchlist[index];
                        return _buildStockCard(stock);
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildStockCard(Map<String, dynamic> stock) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockDetailsScreen(
              initialSymbol: stock['symbol'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
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
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF16A085).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              stock['symbol'][0],
              style: const TextStyle(
                color: Color(0xFF16A085),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          title: Text(
            stock['symbol'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF2C3E50),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFE57373)),
            onPressed: () => _removeStock(stock['id']),
          ),
          subtitle: const Text(
            'Tap to view details',
            style: TextStyle(color: Color(0xFF34495E)),
          ),
        ),
      ),
    );
  }
}
