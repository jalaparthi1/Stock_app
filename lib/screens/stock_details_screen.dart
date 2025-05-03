import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/finnhub_service.dart';

class StockDetailsScreen extends StatefulWidget {
  final String? initialSymbol;

  const StockDetailsScreen({super.key, this.initialSymbol});

  @override
  _StockDetailsScreenState createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  final TextEditingController _stockSymbolController = TextEditingController();
  final FinnhubService _finnhubService = FinnhubService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  final List<String> _defaultStocks = ['AAPL', 'GOOGL', 'MSFT', 'AMZN', 'TSLA'];
  Map<String, Map<String, dynamic>> _stockData = {};
  Set<String> _watchlist = {};

  @override
  void initState() {
    super.initState();
    _fetchWatchlist();

    if (widget.initialSymbol != null) {
      _fetchStockDetails(widget.initialSymbol!);
    } else {
      _fetchDefaultStocks();
    }
  }

  // Fetch Watchlist
  Future<void> _fetchWatchlist() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await _firestore
          .collection('watchlists')
          .doc(userId)
          .collection('stocks')
          .get();

      setState(() {
        _watchlist =
            snapshot.docs.map((doc) => doc['symbol'] as String).toSet();
      });
    } catch (e) {
      print('Error fetching watchlist: $e');
    }
  }

  // Fetch Default Stocks
  Future<void> _fetchDefaultStocks() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, Map<String, dynamic>> fetchedData = {};
    for (String symbol in _defaultStocks) {
      try {
        final data = await _finnhubService.fetchStockData(symbol);
        fetchedData[symbol] = data;
      } catch (e) {
        print('Error fetching data for $symbol: $e');
      }
    }

    setState(() {
      _stockData = fetchedData;
      _isLoading = false;
    });
  }

  // Fetch Specific Stock
  Future<void> _fetchStockDetails(String symbol) async {
    if (symbol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a stock symbol'),
          backgroundColor: Color(0xFFE57373),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _stockData = {};
    });

    try {
      final data =
          await _finnhubService.fetchStockData(symbol.trim().toUpperCase());
      setState(() {
        _stockData = {symbol: data};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data for $symbol: $e'),
          backgroundColor: const Color(0xFFE57373),
        ),
      );
    }
  }

  // Toggle Watchlist
  Future<void> _toggleWatchlist(String symbol) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final watchlistRef =
          _firestore.collection('watchlists').doc(userId).collection('stocks');

      if (_watchlist.contains(symbol)) {
        final existingStock =
            await watchlistRef.where('symbol', isEqualTo: symbol).get();
        for (var doc in existingStock.docs) {
          await doc.reference.delete();
        }

        setState(() {
          _watchlist.remove(symbol);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$symbol removed from watchlist'),
            backgroundColor: const Color(0xFF81C784),
          ),
        );
      } else {
        await watchlistRef.add({'symbol': symbol});
        setState(() {
          _watchlist.add(symbol);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$symbol added to watchlist'),
            backgroundColor: const Color(0xFF81C784),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating watchlist: $e'),
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
          'Stock Details',
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
          child: Column(
            children: [
              Container(
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
                child: TextField(
                  controller: _stockSymbolController,
                  decoration: InputDecoration(
                    labelText: 'Enter Stock Symbol (e.g., AAPL)',
                    labelStyle: const TextStyle(color: Color(0xFF2C3E50)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF16A085)),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFF16A085)),
                      onPressed: () {
                        _fetchStockDetails(_stockSymbolController.text.trim());
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16A085)),
                      ),
                    )
                  : _stockData.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: _stockData.keys.length,
                            itemBuilder: (context, index) {
                              final symbol = _stockData.keys.elementAt(index);
                              final data = _stockData[symbol];
                              return _buildStockCard(symbol, data);
                            },
                          ),
                        )
                      : Center(
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
                              'No stock data available.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockCard(String symbol, Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.asset(
              'assets/stock_image.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Divider(color: Color(0xFFE0E0E0)),
                _buildStockDetailRow('Current Price', '\$${data['c']}'),
                _buildStockDetailRow('High Price', '\$${data['h']}'),
                _buildStockDetailRow('Low Price', '\$${data['l']}'),
                _buildStockDetailRow('Previous Close', '\$${data['pc']}'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _watchlist.contains(symbol)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _watchlist.contains(symbol)
                            ? const Color(0xFFE57373)
                            : const Color(0xFF34495E),
                        size: 30,
                      ),
                      onPressed: () => _toggleWatchlist(symbol),
                    ),
                    Text(
                      _watchlist.contains(symbol)
                          ? 'Added to Watchlist'
                          : 'Add to Watchlist',
                      style: TextStyle(
                        fontSize: 16,
                        color: _watchlist.contains(symbol)
                            ? const Color(0xFF81C784)
                            : const Color(0xFF34495E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF34495E),
            ),
          ),
        ],
      ),
    );
  }
}
