import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:project/components/bar%20graph/bar_data.dart';

class MyBarGraph extends StatefulWidget {
  final Map<String, double> yearlySummary;
  final String year;

  const MyBarGraph({
    super.key,
    required this.yearlySummary,
    required this.year,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  @override
  Widget build(BuildContext context) {
    BarData myBarData = BarData(
        janAmount: widget.yearlySummary['01/${widget.year}'] ?? 0.0,
        febAmount: widget.yearlySummary['02/${widget.year}'] ?? 0.0,
        marAmount: widget.yearlySummary['03/${widget.year}'] ?? 0.0,
        aprAmount: widget.yearlySummary['04/${widget.year}'] ?? 0.0,
        mayAmount: widget.yearlySummary['05/${widget.year}'] ?? 0.0,
        junAmount: widget.yearlySummary['06/${widget.year}'] ?? 0.0,
        julAmount: widget.yearlySummary['07/${widget.year}'] ?? 0.0,
        augAmount: widget.yearlySummary['08/${widget.year}'] ?? 0.0,
        sepAmount: widget.yearlySummary['09/${widget.year}'] ?? 0.0,
        octAmount: widget.yearlySummary['10/${widget.year}'] ?? 0.0,
        novAmount: widget.yearlySummary['11/${widget.year}'] ?? 0.0,
        decAmount: widget.yearlySummary['12/${widget.year}'] ?? 0.0);

    myBarData.initializeBarData();

    return BarChart(
      swapAnimationDuration: const Duration(milliseconds: 1000),
      swapAnimationCurve: Curves.easeOutQuint,
      BarChartData(
          maxY: 2000,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: 500, 
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color.fromARGB(255, 135, 135, 135),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: _getBottomTitles,
            )),
          ),
          barGroups: myBarData.barData
              .map(
                (data) => BarChartGroupData(
                  x: data.x,
                  barRods: [
                    BarChartRodData(
                      color: Colors.amber,
                        toY: data.y,
                        width: 18,
                        borderRadius: BorderRadius.circular(2))
                  ],
                ),
              )
              .toList()),
    );
  }
}

Widget _getBottomTitles(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  Widget text;
  switch (value.toInt()) {
    case 0:
      text = const Text('Jan', style: style);
      break;
    case 1:
      text = const Text('Fev', style: style);
      break;
    case 2:
      text = const Text('Mar', style: style);
      break;
    case 3:
      text = const Text('Abr', style: style);
      break;
    case 4:
      text = const Text('Mai', style: style);
      break;
    case 5:
      text = const Text('Jun', style: style);
      break;
    case 6:
      text = const Text('Jul', style: style);
      break;
    case 7:
      text = const Text('Ago', style: style);
      break;
    case 8:
      text = const Text('Set', style: style);
      break;
    case 9:
      text = const Text('Out', style: style);
      break;
    case 10:
      text = const Text('Nov', style: style);
      break;
    case 11:
      text = const Text('Dez', style: style);
      break;
    default:
      text = const Text('', style: style);
      break;
  }

  // text = Transform.rotate(
  //   angle: 90 * 3.14159265359 / 180, // Converter 15 graus para radianos
  //   child: text,
  // );

  return SideTitleWidget(child: text, axisSide: meta.axisSide);
}
