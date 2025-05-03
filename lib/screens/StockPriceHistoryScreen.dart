import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StockComparisonChart extends StatelessWidget {
  final List<Map<String, dynamic>> stockData = [
    {
      'symbol': 'AAPL',
      'current': 205.0,
      'high': 206.99,
      'low': 202.16,
      'close': 213.32
    },
    {
      'symbol': 'GOOGL',
      'current': 164.03,
      'high': 164.97,
      'low': 161.87,
      'close': 161.3
    },
    {
      'symbol': 'AMZN',
      'current': 189.98,
      'high': 192.88,
      'low': 186.4,
      'close': 190.2
    },
    {
      'symbol': 'TSLA',
      'current': 287.21,
      'high': 291.78,
      'low': 279.81,
      'close': 280.52
    },
  ];

  @override
  Widget build(BuildContext context) {
    double maxY = _getMaxY();
    double chartMaxY = maxY + 50 > 320 ? 320 : maxY + 50;

    return Scaffold(
      appBar: AppBar(title: const Text("Stock Price Comparison")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bar chart
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: _generateBarGroups(),
                  groupsSpace: 24,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < stockData.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 6,
                              child: Text(
                                stockData[index]['symbol'],
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  maxY: chartMaxY,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Legend
            Wrap(
              spacing: 20,
              children: [
                _buildLegend(Colors.blue, 'Current'),
                _buildLegend(Colors.green, 'High'),
                _buildLegend(Colors.orange, 'Low'),
                _buildLegend(Colors.red, 'Close'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Get maximum Y value from the stock data
  double _getMaxY() {
    double max = 0.0;
    for (var data in stockData) {
      double localMax = [
        data['current'],
        data['high'],
        data['low'],
        data['close']
      ].reduce((a, b) => a > b ? a : b);
      if (localMax > max) {
        max = localMax;
      }
    }
    return max;
  }

  // Create bar groups for each stock
  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(stockData.length, (i) {
      final item = stockData[i];
      return BarChartGroupData(
        x: i,
        barsSpace: 4,
        barRods: [
          BarChartRodData(toY: item['current'], color: Colors.blue, width: 10),
          BarChartRodData(toY: item['high'], color: Colors.green, width: 10),
          BarChartRodData(toY: item['low'], color: Colors.orange, width: 10),
          BarChartRodData(toY: item['close'], color: Colors.red, width: 10),
        ],
      );
    });
  }

  // Build legend for bar colors
  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
