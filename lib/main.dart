import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:project/hive%20classes/boxes.dart';
import 'package:project/hive%20classes/expense.dart';
import 'package:project/hive%20classes/income.dart';
import 'package:project/hive%20classes/note.dart';
//import 'package:project/screens/auth_screen.dart';
import 'package:project/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 

  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(IncomeAdapter());
  Hive.registerAdapter(NoteAdapter());
  boxExpenses = await Hive.openBox<Expense>('expenseBox');
  boxIncomes = await Hive.openBox<Income>('incomesBox');
  boxNotes = await Hive.openBox<Note>('notesBox');
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(
      const ProviderScope(child: MyApp()),
    );
  });

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue, colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.green),
      ),
      home: ExpenseTracker(),
    );
  }
}