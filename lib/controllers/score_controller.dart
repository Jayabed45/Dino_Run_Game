import '../models/score_model.dart';
import '../utils/database_helper.dart';

class ScoreController {
  Future<void> saveScore(int score) async {
    await DatabaseHelper.insertScore(score);
  }

  Future<List<Score>> getHighScores() async {
    return await DatabaseHelper.getScores();
  }
}
