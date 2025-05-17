import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/dino_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pass the context to the game for navigation
    final DinoGame game = DinoGame(context: context);

    return Scaffold(
      backgroundColor: Colors.white, // Ensure light background
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dino Run',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  StreamBuilder<int>(
                    stream: Stream.periodic(
                      const Duration(milliseconds: 100),
                      (_) => game.gameController.score,
                    ),
                    builder: (context, snapshot) {
                      final score = snapshot.data ?? 0;
                      return Text(
                        'Score: $score',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  // Add a colored background to verify rendering area
                  Container(
                    color: Colors.lightBlue[100],
                    width: double.infinity,
                    height: double.infinity,
                    child: const Center(
                      child: Text(
                        'Game Area',
                        style: TextStyle(color: Colors.black45),
                      ),
                    ),
                  ),
                  // Game widget on top of background
                  GameWidget<DinoGame>(
                    game: game,
                    loadingBuilder:
                        (context) => const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Loading game...',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                    errorBuilder:
                        (context, error) => Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.red[100],
                            child: Text(
                              'An error occurred: $error',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                    backgroundBuilder:
                        (context) => Container(color: Colors.lightBlue[200]),
                    overlayBuilderMap: {
                      'controls': (context, game) {
                        return Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Tap or press Space/Up to jump',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      'debug': (context, game) {
                        return Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black54,
                            child: const Text(
                              'Debug Mode',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    },
                    initialActiveOverlays: const ['controls', 'debug'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
