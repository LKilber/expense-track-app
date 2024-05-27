import 'package:hive/hive.dart';
part 'note.g.dart';

@HiveType(typeId: 3)
class Note {
  Note({
    required this.note,
    required this.id,
  });
  
  @HiveField(0)
  final String note;
  @HiveField(1)
  final String id;
}