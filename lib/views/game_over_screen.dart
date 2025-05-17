import 'package:flutter/material.dart';
import '../controllers/score_controller.dart';

class GameOverScreen extends StatelessWidget {
  final int score;
  final ScoreController scoreController = ScoreController();
  GameOverScreen({super.key, required this.score});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Game Over!", style: TextStyle(fontSize: 30)),
            Text("Score: $score", style: TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Restart"),
            ),
            FutureBuilder(
              future: scoreController.getHighScores(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text("High Score: ${snapshot.data!.first.score}");
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
