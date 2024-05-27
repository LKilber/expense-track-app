import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project/components/pie_chart.dart';

class ChartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> transactionsList;

  ChartScreen(this.transactionsList);

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categoryExpenses = {};

    transactionsList.sort((a, b) {
      final double amountA = double.tryParse(a['amount'].toString()) ?? 0.0;
      final double amountB = double.tryParse(b['amount'].toString()) ?? 0.0;
      return amountB.compareTo(amountA);
    });

    for (var transaction in transactionsList) {
      final String? category = transaction['category'];

      final String? amountString = transaction['amount'].toString(); // Garanta que seja uma String
      final double? amountDouble = double.tryParse(amountString ?? '');

      if (category != null && amountDouble != null) {
        if (categoryExpenses.containsKey(category)) {
          categoryExpenses[category] = categoryExpenses[category]! + amountDouble;
        } else {
          categoryExpenses[category] = amountDouble;
        }
      }
    }

    final double totalExpenses = categoryExpenses.values.fold(0, (a, b) => a + b);

    final List<PieChartSectionData> pieChartSections = categoryExpenses.entries
        .map((entry) => PieChartSectionData(
              color: _getColor(entry.key),
              value: entry.value,
              title: '${((entry.value / totalExpenses) * 100).toStringAsFixed(1)}%', // Display percentage
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribuição de Despesas'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 40, 40, 40),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 20, 20, 20), Color.fromARGB(255, 20, 20, 20)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              flex: 2,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 40, 40, 40),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: MyPieChart(
                    pieChartSections: pieChartSections,
                    totalExpenses: totalExpenses,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 40, 40, 40),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: categoryExpenses.length,
                  itemBuilder: (context, index) {
                    final category = categoryExpenses.keys.elementAt(index);
                    final amount = categoryExpenses[category]!;

                    return ListTile(
                      leading: _getCategoryIcon(category),
                      title: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      trailing: Text(
                        'R\$ ${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.amber,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String category) {
    switch (category) {
      case 'Alimentação':
        return Colors.redAccent;
      case 'Transporte':
        return Colors.blueAccent;
      case 'Lazer':
        return Colors.greenAccent;
      case 'Moradia':
        return Colors.orangeAccent;
      case 'Saúde':
        return Colors.purpleAccent; // Alterado para roxo para diferenciar de laranja
      case 'Outros':
        return Colors.amberAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'Alimentação':
        return const Icon(Icons.restaurant, color: Colors.redAccent);
      case 'Transporte':
        return const Icon(Icons.directions_car, color: Colors.blueAccent);
      case 'Lazer':
        return const Icon(Icons.local_movies, color: Colors.greenAccent);
      case 'Moradia':
        return const Icon(Icons.home, color: Colors.orangeAccent);
      case 'Saúde':
        return const Icon(Icons.healing, color: Colors.purpleAccent);
      case 'Outros':
        return const Icon(Icons.attach_money, color: Colors.amberAccent);
      default:
        return const Icon(Icons.category, color: Colors.grey);
    }
  }
}
