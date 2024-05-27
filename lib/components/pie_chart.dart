import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyPieChart extends StatelessWidget {
  final List<PieChartSectionData> pieChartSections;
  final double totalExpenses;

  MyPieChart({
    Key? key,
    required this.pieChartSections,
    required this.totalExpenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          swapAnimationDuration: const Duration(milliseconds: 750),
          swapAnimationCurve: Curves.easeInOutQuint,
          PieChartData(
            sections: pieChartSections,
            borderData: FlBorderData(show: false),
            centerSpaceRadius: 90,
            sectionsSpace: 4,
          ),
        ),
        // Coloque o texto no centro do gráfico
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Personalize a cor conforme necessário
                  ),
                ),
                Text(
                  'R\$ ${totalExpenses.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber, // Personalize a cor conforme necessário
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
