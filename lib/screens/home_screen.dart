//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/components/my_fab_expandable.dart';
import 'package:project/hive%20classes/boxes.dart';
import 'package:project/hive%20classes/expense.dart';
import 'package:project/hive%20classes/income.dart';
import 'package:project/screens/notes_screen.dart';
import 'package:uuid/uuid.dart';
import 'chart_screen.dart';
import 'insights_screen.dart';

class ExpenseTracker extends StatefulWidget {
  
  const ExpenseTracker({super.key});

  @override
  _ExpenseTrackerState createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {
  final List<Map<String, dynamic>> expensesList = [];
  final List<Map<String, dynamic>> incomesList = [];
  final List<Map<String, dynamic>> notesList = [];
  final uuid = const Uuid();

  void _updateExpenses() async {
    final List<dynamic> expenses = boxExpenses.values.toList();
    expensesList.clear();
    for (var expense in expenses) {
      final expenseMap = {
        'id': expense.id,
        'date': expense.date,
        'category': expense.category,
        'amount': expense.amount,
        'parcels': expense.parcels,
        'description': expense.description,
        'parcelDates': expense.parcelDates,
      };
      expensesList.add(expenseMap);
    }
  }

  void _updateIncomes() async {
    final List<dynamic> incomes = boxIncomes.values.toList();
    incomesList.clear();
    for (var income in incomes) {
      final incomeMap = {
        'id': income.id,
        'date': income.date,
        'amount': income.amount,
      };
      incomesList.add(incomeMap);
    }
  }

  DateTime selectedDate = DateTime.now();
  DateTime selectedDateFilter = DateTime.now();
  String selectedCategory = 'Alimentação';

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController parcelController =
      TextEditingController(text: '1');

  final List<String> categories = [
    'Alimentação',
    'Transporte',
    'Lazer',
    'Outros'
  ];

  List<Map<String, dynamic>> _filteredExpenses() {
    final selectedDateMonth =
        DateTime(selectedDateFilter.year, selectedDateFilter.month);

    // Calcula a data de início (dia 27 do mês anterior)
    final start =
        DateTime(selectedDateMonth.year, selectedDateMonth.month - 1, 26);
    // Calcula a data de término (dia 26 do mês atual)
    final end = DateTime(selectedDateMonth.year, selectedDateMonth.month, 27);

    final filteredExpenses = expensesList.where((expense) {
      final parcelDates = (expense['parcelDates'] as List?)?.cast<String>();
      if (parcelDates == null || parcelDates.isEmpty) {
        return false;
      }
      return parcelDates.any((parcelDateStr) {
        final parcelDate = DateFormat('dd/MM/yyyy').parse(parcelDateStr);
        return parcelDate.isAfter(start) && parcelDate.isBefore(end);
      });
    }).toList();

    filteredExpenses.sort((a, b) {
      final DateTime dateA =
          DateFormat('dd/MM/yyyy').parse(a['parcelDates'][0]);
      final DateTime dateB =
          DateFormat('dd/MM/yyyy').parse(b['parcelDates'][0]);
      return dateB.compareTo(dateA);
    });

    return filteredExpenses;
  }

List<Map<String, dynamic>> _filteredIncomes() {
  final selectedDateMonth = DateTime(selectedDateFilter.year, selectedDateFilter.month);

  // Calcula a data de início (dia 27 do mês anterior)
  final start = DateTime(selectedDateMonth.year, selectedDateMonth.month - 1, 26);
  // Calcula a data de término (dia 26 do mês atual)
  final end = DateTime(selectedDateMonth.year, selectedDateMonth.month, 27);

  final formatter = DateFormat('dd/MM/yyyy'); // Formato de data esperado

  final filteredIncomes = incomesList.where((income) {
    final DateTime incomeDate = formatter.parse(income['date']);
    return incomeDate.isAfter(start) && incomeDate.isBefore(end);
  }).toList();

  filteredIncomes.sort((a, b) {
    final DateTime dateA = formatter.parse(a['date']);
    final DateTime dateB = formatter.parse(b['date']);
    return dateB.compareTo(dateA);
  });

  return filteredIncomes;
}

  @override
  Widget build(BuildContext context) {
    _updateExpenses();
    _updateIncomes();

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.indigo.shade300],
          ),
        ),
        child: _buildBody(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

AppBar _buildAppBar() {
  double totalExpenses = _getTotalExpenses();
  double totalIncomes = _getTotalIncomes();
  double balance = totalIncomes - totalExpenses;

  return AppBar(
    toolbarHeight: 120.0,
    elevation: 4,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 30, 30, 30),
            Color.fromARGB(255, 30, 30, 30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10.0),
          Text(
            'Balanço',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Text(
            'R\$${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoColumn(Icons.arrow_circle_up, 'Receitas', 'R\$${totalIncomes.toStringAsFixed(2)}', Colors.greenAccent),
              const SizedBox(width: 50.0),
              _buildInfoColumn(Icons.arrow_circle_down, 'Despesas', 'R\$${totalExpenses.toStringAsFixed(2)}', Colors.redAccent),
            ],
          ),
        ],
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(48.0),
      child: Center(
        child: _buildFilterMonthYearPicker(),
      ),
    ),
  );
}

Widget _buildInfoColumn(IconData iconData, String description, String value, Color valueColor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: valueColor,
            size: 40.0,
          ),
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}




  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: _buildExpensesList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterMonthYearPicker() {
    return Center(
      child: Container(
        width: 240, // Ajuste a largura conforme necessário
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20), // Borda arredondada
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                // Adicione aqui a lógica para retroceder um mês
                setState(() {
                  selectedDateFilter = DateTime(
                      selectedDateFilter.year, selectedDateFilter.month - 1);
                });
              },
              color: Colors.white,
            ),
            ElevatedButton(
              onPressed: () {
                _selectMonthYear(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .transparent, // Define a cor de fundo do botão como transparente
                elevation: 0, // Remove a sombra do botão
              ),
              child: Align(
                alignment: Alignment.center, // Centraliza o texto
                child: Text(
                  DateFormat('MM/yyyy').format(selectedDateFilter),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                // Adicione aqui a lógica para avançar um mês
                setState(() {
                  selectedDateFilter = DateTime(
                      selectedDateFilter.year, selectedDateFilter.month + 1);
                });
              },
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildExpensesList() {
  final selectedDateMonth =
      DateTime(selectedDateFilter.year, selectedDateFilter.month);
  final filteredExpenses = _filteredExpenses();
  final filteredIncomes = _filteredIncomes();

  final List<Widget> combinedList = [];

  for (final expense in filteredExpenses) {
    final amount = double.parse(expense['amount'].toStringAsFixed(2));
    final category = expense['category'];
    final description = expense['description'];

    final parcelDates =
        (expense['parcelDates'] as List?)?.cast<String>() ?? [];
    final parcelDateIndex = parcelDates.indexWhere((parcelDateStr) {
      // Calcula a data de início (dia 27 do mês anterior)
      final start =
          DateTime(selectedDateMonth.year, selectedDateMonth.month - 1, 26);
      // Calcula a data de término (dia 26 do mês atual)
      final end = DateTime(selectedDateMonth.year, selectedDateMonth.month, 27);
      final parcelDate = DateFormat('dd/MM/yyyy').parse(parcelDateStr);
      return parcelDate.isAfter(start) && parcelDate.isBefore(end);
    });

    final currentParcel = parcelDateIndex != -1 ? parcelDateIndex + 1 : 0;
    final totalParcels = expense['parcels'] ?? 1;
    final parcelRepresentation = '$currentParcel/$totalParcels';

    final expenseDate =
        DateFormat('dd/MM/yyyy').parse(expense['parcelDates'][currentParcel - 1]);

    final formattedExpenseDate =
        DateFormat('dd/MM/yyyy (E)', 'pt_BR').format(expenseDate);

    combinedList.add(
      Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart ||
              direction == DismissDirection.startToEnd) {
            _deleteTransaction(expense, "Expense");
            setState(() {});
          }
        },
        background: Container(
          color: Colors.red,
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
        child: FlipCard(
          key: UniqueKey(),
          flipOnTouch: true,
          direction: FlipDirection.VERTICAL,
          front: Card(
            color: const Color.fromARGB(255, 40, 40, 40),
            elevation: 5,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: 40,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: _getCategoryIcon(category),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'R\$ ${amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          Text(
                            parcelRepresentation,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.amber,
                        ),
                      ),
                      Text(
                        formattedExpenseDate,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          back: Card(
            color: const Color.fromARGB(255, 40, 40, 40),
            elevation: 5,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListTile(
              title: const Text(
                'Descrição:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                description,
                style: const TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  for (final income in filteredIncomes) {
    final amount = double.parse(income['amount'].toStringAsFixed(2));

    combinedList.add(
      Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart ||
              direction == DismissDirection.startToEnd) {
            _deleteTransaction(income, "Income");
            setState(() {});
          }
        },
        background: Container(
          color: Colors.green, // Defina a cor para a ação de deletar
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
        child: Card(
          color: const Color.fromARGB(255, 40, 40, 40),
          elevation: 5,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            title: Center(
              child: Text(
                'R\$ ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Defina a cor para as entradas (incomes)
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 20, 20, 20),
          Color.fromARGB(255, 20, 20, 20)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: ListView(
      children: combinedList,
    ),
  );
}


  // Lista de categorias com ícones (substitua pelos seus ícones e nomes reais)
  List<Map<String, dynamic>> categoryList = [
    {"name": "Alimentação", "icon": Icons.fastfood},
    {"name": "Transporte", "icon": Icons.directions_car},
    {"name": "Lazer", "icon": Icons.local_movies},
    {"name": "Moradia", "icon": Icons.home},
    {"name": "Saúde", "icon": Icons.healing},
    {"name": "Outros", "icon": Icons.attach_money},
  ];

  void _openExpenseDialog(BuildContext context) {
    amountController.clear();
    parcelController.clear();
    descriptionController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 30, 30, 30),
                    Color.fromARGB(255, 30, 30, 30)
                  ],
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Adicionar Despesa',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCategoryButtons(), // Utilize os novos botões de categoria aqui
                  const SizedBox(height: 20),
                  _buildDateButton(), // Utilize o novo botão de data aqui
                  const SizedBox(height: 20),
                  _buildDescriptionTextField(), // Campo de descrição
                  const SizedBox(height: 20),
                  _buildAmountAndParcelTextField(), // Campo de valor
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Feche o diálogo
                          },
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Salvar a nova meta e fechar o diálogo
                            _addTransaction('Expense');
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                  color: Colors.white, width: 2),
                            ),
                          ),
                          child: const Text(
                            'Adicionar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openProfitDialog(BuildContext context) {
  amountController.clear();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 30, 30, 30),
                Color.fromARGB(255, 30, 30, 30)
              ],
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Adicionar Entrada',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildDateButton(),
              const SizedBox(height: 20),
              Flexible(
                flex: 2,
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Valor',
                    hintStyle: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 205, 205, 205)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _addTransaction('Profit');
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      child: const Text(
                        'Adicionar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Widget _buildDescriptionTextField() {
    return TextField(
      controller: descriptionController,
      decoration: const InputDecoration(
        hintText: 'Descrição',
        hintStyle: TextStyle(
          color: Colors.white70,
          fontSize: 16.0,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 205, 205, 205)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAmountAndParcelTextField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          flex: 2, // Valor maior para ocupar mais espaço
          child: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Valor',
              hintStyle: TextStyle(
                color: Colors.white70,
                fontSize: 16.0,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 205, 205, 205)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 16), // Espaço entre os campos
        Flexible(
          flex: 1, // Valor menor para ocupar menos espaço
          child: TextField(
            controller: parcelController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Parcelas',
              hintStyle: TextStyle(
                color: Colors.white70,
                fontSize: 16.0,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 205, 205, 205)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryButtons() {
    return CategoryButtons(
      categoryList: categoryList,
      selectedCategory:
          selectedCategory, // Passe a variável de estado para o widget
      onCategorySelected: (String category) {
        setState(() {
          selectedCategory = category; // Use setState para atualizar a variável
        });
      },
    );
  }

  Widget _buildDateButton() {
    return DateButton(onDateSelected: (DateTime picked) {
      selectedDate = picked;
    });
  }

  Widget _buildFloatingActionButton() {
    return ExpandableFab(
      distance: 112,
      children: [
        ActionButton(
          onPressed: () => _openProfitDialog(context),
          icon: const Icon(
            Icons.arrow_upward,
            color: Colors.greenAccent,
            size: 32,
          ),
        ),
        ActionButton(
          onPressed: () => _openExpenseDialog(context),
          icon: const Icon(Icons.arrow_downward,
              color: Colors.redAccent, size: 32),
        ),
        ActionButton(
          onPressed: () => (),
          icon: const Icon(Icons.settings, color: Colors.blueAccent, size: 32),
        ),
      ],
    );
  }

BottomAppBar _buildBottomAppBar() {
  return BottomAppBar(
    shape: const CircularNotchedRectangle(),
    color: const Color.fromARGB(255, 30, 30, 30),
    clipBehavior: Clip.antiAlias,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _openChartScreen(context);
                },
                icon: const Icon(
                  Icons.pie_chart,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16.0),
              IconButton(
                onPressed: () {
                  _openInsightsScreen(context);
                },
                icon: const Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16.0),
              IconButton(
                onPressed: () {
                  _openNotesScreen(context);
                },
                icon: const Icon(
                  Icons.notes_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        // Use um Spacer para ocupar o espaço entre os botões
        const SizedBox(width:100),
        // Adicione o botão de logoff no canto direito
      ],
    ),
  );
}



  void _openChartScreen(BuildContext context) {
    final filteredExpenses = _filteredExpenses();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChartScreen(filteredExpenses),
      ),
    );
  }

  void _openInsightsScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InsightsScreen(expensesList),
      ),
    );
  }

  void _openNotesScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotesScreen(),
      ),
    );
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

  double _getTotalExpenses() {
    double totalExpenses = 0.0;
    final filteredExpenses = _filteredExpenses();

    for (final expense in filteredExpenses) {
      final expensesAmount = expense['amount'];
      totalExpenses += expensesAmount;
    }
    return totalExpenses;
  }

  double _getTotalIncomes() {
    double totalIncomes = 0.0;
    final filteredIncomes = _filteredIncomes();

    for (final income in filteredIncomes) {
      final incomesAmount = income['amount'];
      totalIncomes += incomesAmount;
    }
    return totalIncomes;
  }

  void _addTransaction(String type) {
    final amount = double.tryParse(amountController.text) ?? 0.00;
    final parcels = int.tryParse(parcelController.text) ?? 1;

    if (amount > 0 && parcels > 0) {
      final DateTime firstTransactionDate =
          selectedDate; // Data da primeira transação
      double parcelAmount = amount;
      if (parcels > 1) {
        parcelAmount = parcelAmount / parcels;
      }

      if (type == 'Expense') {
        final List<String> parcelDates = [];
        for (int currentParcel = 0; currentParcel < parcels; currentParcel++) {
          final parcelDate =
              firstTransactionDate.add(Duration(days: 31 * currentParcel));
          parcelDates.add(DateFormat('dd/MM/yyyy').format(parcelDate));
        }
        var uniqueId = uuid.v4();
        boxExpenses.put(
          uniqueId, 
          Expense(
            id: uniqueId,
            amount: parcelAmount,
            category: selectedCategory,
            date: DateFormat('dd/MM/yyyy').format(selectedDate),
            parcelDates: parcelDates,
            parcels: parcels,
            description: descriptionController.text,
          )
        );
      } else {
        var uniqueId = uuid.v4();
        boxIncomes.put(
          uniqueId, 
          Income(
            id: uniqueId,
            amount: parcelAmount,
            date: DateFormat('dd/MM/yyyy').format(selectedDate),
          )
        );
      }
    }
  }

  void _deleteTransaction(Map<String, dynamic> transaction, String type) {
    if (type == "Expense") {
      if (transaction.containsKey('id')) {
        final String transactionId = transaction['id'];
        boxExpenses.delete(transactionId);
      }
    } else {
      if (transaction.containsKey('id')) {
        final String transactionId = transaction['id'];
        boxIncomes.delete(transactionId);
      }
    }
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: selectedDateFilter,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
      backgroundColor: const Color.fromARGB(255, 40, 40, 40),
      selectedMonthTextColor: Colors.white,
      unselectedMonthTextColor: Colors.white,
      headerColor: Colors.amber,
      selectedMonthBackgroundColor: Colors.grey,
    );

    if (picked != null) {
      setState(() {
        selectedDateFilter = picked;
      });
    }
  }
}

final selectedCategoryProvider = StateProvider<String>((ref) => '');

class CategoryButtons extends ConsumerWidget {
  final List<Map<String, dynamic>> categoryList;
  final String selectedCategory;
  final void Function(String) onCategorySelected;

  CategoryButtons({
    required this.categoryList,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Wrap(
      spacing: 8.0, // Ajuste o espaçamento horizontal entre os botões
      runSpacing:
          8.0, // Ajuste o espaçamento vertical entre as linhas de botões
      children: categoryList.map((category) {
        bool isSelected = selectedCategory == category["name"];

        return ElevatedButton(
          onPressed: () {
            ref.read(selectedCategoryProvider.notifier).state =
                category["name"];
            onCategorySelected(category["name"]);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(
                20.0), // Aumente o preenchimento do botão para um tamanho maior
            shape: const CircleBorder(),
            backgroundColor: isSelected
                ? Colors.amber
                : Colors.white, // Cor de fundo do botão quando selecionado
            elevation: 10,
          ),
          child: Icon(
            category["icon"],
            color: isSelected ? Colors.white : Colors.black,
            size: 30.0, // Aumente o tamanho do ícone para botões maiores
          ),
        );
      }).toList(),
    );
  }
}

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class DateButton extends ConsumerWidget {
  final void Function(DateTime) onDateSelected;

  DateButton({
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    return ElevatedButton(
      onPressed: () {
        _selectDate(context, ref);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Cor de fundo
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            color: Colors.black, // Cor do ícone
          ),
          const SizedBox(width: 10),
          Text(
            DateFormat('dd/MM/yyyy').format(selectedDate),
            style: const TextStyle(
              color: Colors.black, // Cor do texto
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: ref.watch(selectedDateProvider),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            // Defina um tema escuro aqui
            primaryColor: Colors.white, // Cor do texto e ícones
            hintColor: Colors.white, // Cor do texto selecionado
            dialogBackgroundColor:
                const Color.fromARGB(255, 40, 40, 40), // Cor de fundo preta
          ),
          child: child!,
        );
      },
    );
    if (picked != null &&
        picked != ref.read(selectedDateProvider.notifier).state) {
      ref.read(selectedDateProvider.notifier).state = picked;
      onDateSelected(picked);
    }
  }
}
