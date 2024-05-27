import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/components/bar%20graph/bar_graph.dart';

class InsightsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactionsList;

  InsightsScreen(this.transactionsList);

  @override
  _InsightsScreenState createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int selectedYear = DateTime.now().year; // Ano selecionado inicialmente
  List<Map<String, dynamic>> transactionsList = [];

  @override
  void initState() {
    super.initState();
    transactionsList = widget.transactionsList;
  }

  void goToNextYear() {
    setState(() {
      selectedYear++; // Aumenta o ano
    });
  }

  void goToPreviousYear() {
    setState(() {
      selectedYear--; // Diminui o ano
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, double>> monthlyCategoryTotals = {};
    Map<String, double> monthlyTotals = {};

    // Agrupe os gastos por categoria e mês
    for (var transaction in transactionsList) {
      String category = transaction['category'];
      double amount = transaction['amount']?.toDouble() ?? 0.0;
      List<Object?> parcelDatesObject =
          transaction['parcelDates'] as List<Object?>;
      List<String> parcelDates = parcelDatesObject
          .map((obj) => obj.toString())
          .toList(); // Supondo que 'parcelDates' seja uma lista de strings no formato "dd/MM/yyyy".

      for (String dateString in parcelDates) {
        DateTime date = DateFormat('dd/MM/yyyy').parse(dateString);

        // Crie um mapa para a categoria se não existir
        monthlyCategoryTotals.putIfAbsent(category, () => {});

        String monthYear = DateFormat('MM/yyyy').format(date);

        // Atualize os totais mensais por categoria
        monthlyCategoryTotals[category]!.update(
          monthYear,
          (value) => (value + amount),
          ifAbsent: () => amount,
        );

        // Verifique se a data da transação pertence ao ano selecionado
        if (date.year == selectedYear) {
          // Ajuste para considerar transações do dia 27 como do mês seguinte
          if (date.day >= 27) {
            date = DateTime(date.year, date.month + 1, date.day);
            monthYear = DateFormat('MM/yyyy').format(date);
          }

          // Atualize os totais mensais gerais
          monthlyTotals.update(
            monthYear,
            (value) => (value + amount),
            ifAbsent: () => amount,
          );
        }
      }
    }

    // Calcule a média de gastos entre os meses para cada categoria
    Map<String, double> categoryAverages =
        calculateCategoryAverages(monthlyCategoryTotals);

    // Obtém uma lista de pares (categoria, média) e a ordena em ordem decrescente
    List<MapEntry<String, double>> sortedCategoryAverages =
        categoryAverages.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // Obtém a lista de todas as categorias disponíveis
    List<String> allCategories = [
      'Alimentação',
      'Transporte',
      'Lazer',
      'Moradia',
      'Saúde',
      'Outros',
    ];

    // Cria uma lista de widgets ListTile
    List<Widget> categoryListTiles = [];

    for (String category in allCategories) {
      double average = 0.0;

      // Procura a média correspondente à categoria na lista classificada
      for (var entry in sortedCategoryAverages) {
        if (entry.key == category) {
          average = entry.value;
          break;
        }
      }

      categoryListTiles.add(_averageInfo(category, average));
    }

// Restante do código do build ...

    return Scaffold(
  appBar: AppBar(
    title: const Text('Média de Gastos'),
    centerTitle: true,
    backgroundColor: const Color.fromARGB(255, 40, 40, 40),
  ),
  body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 20, 20, 20),
          Color.fromARGB(255, 20, 20, 20),
        ],
      ),
    ),
    child: Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              AnimatedContainer(
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
                child: MyBarGraph(
                    yearlySummary: monthlyTotals,
                    year: selectedYear.toString()),
              ),
              Column(
                children: [
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                            Icons.arrow_circle_left), // Ícone da seta para a esquerda
                        color: Colors.white,
                        onPressed: () {
                          goToPreviousYear(); // Chama a função para ir para o ano anterior
                        },
                      ),
                      Text(
                        selectedYear.toString(), // Exibe o ano selecionado
                        style: const TextStyle(
                          color: Colors.white, // Define a cor do texto como branca
                          fontSize: 14, // Ajuste o tamanho do texto conforme necessário
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                            Icons.arrow_circle_right), // Ícone da seta para a direita
                        color: Colors.white,
                        onPressed: () {
                          goToNextYear(); // Chama a função para ir para o próximo ano
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
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
            child: ListView(children: categoryListTiles),
          ),
        ),
      ],
    ),
  ),
);

  }

  Widget _averageInfo(String category, double average) {
    final categoryIcon = _getCategoryIcon(category);

    return ListTile(
      leading: categoryIcon,
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
        'R\$ ${average.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 18,
          color: Colors.amber,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  Map<String, double> calculateCategoryAverages(
      Map<String, Map<String, double>> monthlyCategoryTotals) {
    Map<String, double> categoryAverages = {};

    monthlyCategoryTotals.forEach((category, monthlyTotals) {
      double totalExpense = monthlyTotals.values.isNotEmpty
          ? monthlyTotals.values.reduce((a, b) => a + b)
          : 0.0;

      // Verifique se a categoria tem transações antes de calcular a média
      double average =
          monthlyTotals.isNotEmpty ? totalExpense / monthlyTotals.length : 0.0;

      categoryAverages[category] = average;
    });

    return categoryAverages;
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
        return Colors
            .purpleAccent; // Alterado para roxo para diferenciar de laranja
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
