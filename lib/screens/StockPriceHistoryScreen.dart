import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StockComparisonChart extends StatelessWidget {
  final List<Map<String, dynamic>> stockData = [
    {'symbol': 'AAPL', 'current': 205.0, 'high': 206.99, 'low': 202.16},
    {'symbol': 'GOOGL', 'current': 164.03, 'high': 164.97, 'low': 161.87},
    {'symbol': 'AMZN', 'current': 189.98, 'high': 192.88, 'low': 186.4},
    {'symbol': 'TSLA', 'current': 287.21, 'high': 291.78, 'low': 279.81},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Price Comparison"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: 300,
                  barGroups: _generateBarGroups(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          if (value % 50 == 0 && value <= 300) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < stockData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                stockData[index]['symbol'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  groupsSpace: 25, // space between stock groups
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(stockData.length, (i) {
      final item = stockData[i];
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: item['current'], color: Colors.blue, width: 8),
        BarChartRodData(toY: item['high'], color: Colors.green, width: 8),
        BarChartRodData(toY: item['low'], color: Colors.red, width: 8),
      ]);
    });
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _LegendItem(color: Colors.blue, label: 'Current'),
        _LegendItem(color: Colors.green, label: 'High'),
        _LegendItem(color: Colors.red, label: 'Low'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
