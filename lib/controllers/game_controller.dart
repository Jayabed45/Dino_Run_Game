import '../models/player_model.dart';

class GameController {
  final Player player = Player();
  bool isGameOver = false;
  int score = 0;

  // Jump physics constants
  final double gravity = 20.0; // Higher gravity for more responsive jumps
  final double jumpVelocity = -600.0; // Stronger initial jump velocity

  void jump() {
    if (!player.isJumping && !isGameOver) {
      player.velocityY = jumpVelocity;
      player.isJumping = true;
    }
  }

  void update(double dt) {
    if (isGameOver) return;

    // Apply gravity with proper time scaling
    player.velocityY += gravity;

    // Update position using velocity (with proper time scaling)
    // Multiply by dt to make movement frame-rate independent
    player.y += player.velocityY * dt;

    // Ground collision detection
    if (player.y > 0) {
      player.y = 0;
      player.velocityY = 0;
      player.isJumping = false;
    }

    score++;
  }

  void reset() {
    player.y = 0;
    player.velocityY = 0;
    player.isJumping = false;
    isGameOver = false;
    score = 0;
  }
}
