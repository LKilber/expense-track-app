import 'package:hive/hive.dart';
part 'expense.g.dart';

@HiveType(typeId: 1)
class Expense {
  Expense({
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.parcelDates,
    required this.parcels,
    required this.id,
  });
  
  @HiveField(0)
  final double amount;
  @HiveField(1)
  final String category;
  @HiveField(2)
  final String date;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final List<dynamic> parcelDates;
  @HiveField(5)
  final int parcels;
  @HiveField(6)
  final String id;
}