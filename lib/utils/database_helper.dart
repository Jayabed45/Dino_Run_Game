import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/score_model.dart';

class DatabaseHelper {
  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'scores.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE scores(id INTEGER PRIMARY KEY, score INTEGER)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertScore(int score) async {
    final db = await initDB();
    await db.insert('scores', {'score': score});
  }

  static Future<List<Score>> getScores() async {
    final db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query('scores');
    return List.generate(maps.length, (i) {
      return Score(id: maps[i]['id'], score: maps[i]['score']);
    });
  }
}
