import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../controllers/score_controller.dart';
import '../views/game_over_screen.dart';

class DinoGame extends FlameGame with TapDetector, KeyboardEvents {
  late final SpriteComponent dino;
  final GameController gameController = GameController();
  final ScoreController scoreController = ScoreController();

  // Ground level position (y-coordinate)
  final double groundLevel = 300;

  // Jump height control
  final double maxJumpHeight = 900; // Maximum visual jump height in pixels

  // Add obstacle components
  final List<SpriteComponent> obstacles = [];
  double obstacleSpawnTimer = 0;
  final double obstacleSpawnInterval = 1.5; // Spawn every 1.5 seconds

  // Flag to control game over transition
  bool isTransitioningToGameOver = false;

  // Reference to the BuildContext for navigation
  final BuildContext? context;

  DinoGame({this.context});

  @override
  Future<void> onLoad() async {
    // Load images
    try {
      await images.loadAll([
        'dino.png',
        'cactus.png', // Make sure to add this image to your assets
      ]);
    } catch (e) {
      print("Error loading images: $e");
      // At minimum, load the dino image
      await images.load('dino.png');
    }

    // Create dino sprite - Position it at ground level initially
    dino = SpriteComponent(
      sprite: Sprite(images.fromCache('dino.png')),
      size: Vector2(60, 60),
      position: Vector2(50, groundLevel), // Ground level position
    );

    // Add components
    add(dino);

    // Reset game state
    gameController.reset();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameController.isGameOver || isTransitioningToGameOver) {
      return;
    }

    // Update game logic with small time step for more stable physics
    // Use a smaller dt value if the game is running slowly
    final double physicsTimeStep = dt.clamp(
      0.0,
      0.016,
    ); // Cap at 60fps equivalent
    gameController.update(physicsTimeStep);

    // IMPORTANT FIX: Calculate dino position with proper scaling
    // Map the player's physics position to screen position
    // When player.y is negative (due to negative velocity = jumping up), the dino should move UP
    // Negative player.y * scaling factor = upward movement from groundLevel

    // Calculate jump position - negative player.y means we're in the air
    // Scale the physics value to visual pixels with maxJumpHeight
    double jumpOffset = 0;
    if (gameController.player.y < 0) {
      // Map from physics coordinates to screen coordinates
      // Note: player.y is negative when jumping up, so we negate it again
      jumpOffset = -gameController.player.y * (maxJumpHeight / 500.0);
    }

    // Apply the calculated position - subtract jumpOffset to move up from groundLevel
    dino.position.y = groundLevel - jumpOffset;

    // Handle obstacle spawning
    obstacleSpawnTimer += dt;
    if (obstacleSpawnTimer >= obstacleSpawnInterval) {
      _spawnObstacle();
      obstacleSpawnTimer = 0;
    }

    // Update obstacles and check for collision
    for (final obstacle in [...obstacles]) {
      // Create a copy of the list to avoid concurrent modification
      obstacle.position.x -= 200 * dt; // Move obstacles to the left

      // Remove obstacles that are off-screen
      if (obstacle.position.x < -obstacle.size.x) {
        obstacle.removeFromParent();
        obstacles.remove(obstacle);
        continue; // Skip collision check for removed obstacles
      }

      // Check for collision
      if (_checkCollision(dino, obstacle)) {
        _handleGameOver();
        break;
      }
    }
  }

  void _spawnObstacle() async {
    try {
      // Use cactus image for obstacles instead of dino
      String obstacleImage = 'cactus.png';
      // Fallback to dino image if cactus image isn't available
      if (!images.containsKey(obstacleImage)) {
        print("Cactus image not found, using fallback image");
        obstacleImage = 'dino.png';
      }

      final obstacle = SpriteComponent(
        sprite: Sprite(images.fromCache(obstacleImage)),
        size: Vector2(40, 60), // Taller for cactus
        position: Vector2(
          size.x,
          groundLevel - 20,
        ), // Position at ground level, but adjust for height
      );

      add(obstacle);
      obstacles.add(obstacle);
    } catch (e) {
      print("Error spawning obstacle: $e");
    }
  }

  bool _checkCollision(SpriteComponent a, SpriteComponent b) {
    // Simple rectangle collision
    final aRect = Rect.fromLTWH(
      a.position.x,
      a.position.y,
      a.size.x * 0.8,
      a.size.y * 0.8,
    );

    final bRect = Rect.fromLTWH(
      b.position.x,
      b.position.y,
      b.size.x * 0.8,
      b.size.y * 0.8,
    );

    return aRect.overlaps(bRect);
  }

  void _handleGameOver() async {
    if (isTransitioningToGameOver) return;
    isTransitioningToGameOver = true;
    gameController.isGameOver = true;

    // Save score
    await scoreController.saveScore(gameController.score);

    // Navigate to game over screen
    if (context != null) {
      // Use a delayed future to avoid immediate navigation during render
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.push(
          context!,
          MaterialPageRoute(
            builder: (context) => GameOverScreen(score: gameController.score),
          ),
        ).then((_) {
          // Reset game when returning from game over screen
          gameController.reset();
          for (var obstacle in [...obstacles]) {
            obstacle.removeFromParent();
          }
          obstacles.clear();
          isTransitioningToGameOver = false;
        });
      });
    }
  }

  @override
  void onTap() {
    gameController.jump();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        gameController.jump();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
