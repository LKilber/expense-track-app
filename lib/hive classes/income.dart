import 'package:hive/hive.dart';
part 'income.g.dart';

@HiveType(typeId: 2)
class Income {
  Income({
    required this.amount,
    required this.date,
    required this.id,
  });
  
  @HiveField(0)
  final double amount;
  @HiveField(1)
  final String date;
  @HiveField(2)
  final String id;
}