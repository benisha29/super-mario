import 'dart:async';
import 'package:flutter/material.dart';
import 'button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double marioX = 0;
  double marioY = 1;
  bool isJumping = false;
  bool isRunning = false;
  bool isDead = false;
  bool facingRight = true;
  String statusText = 'Use arrows to move and jump';

  double jumpTime = 0;
  double initialY = 1;
  Timer? jumpTimer;
  Timer? runTimer;

  final List<double> obstaclePositions = [-0.7, -0.1, 0.4, 0.85];

  void resetGame() {
    jumpTimer?.cancel();
    runTimer?.cancel();
    setState(() {
      isDead = false;
      marioX = 0;
      marioY = 1;
      isJumping = false;
      isRunning = false;
      facingRight = true;
      statusText = 'Use arrows to move and jump';
    });
  }

  void animateRun() {
    if (isDead) return;
    setState(() => isRunning = true);
    runTimer?.cancel();
    runTimer = Timer(const Duration(milliseconds: 150), () {
      setState(() => isRunning = false);
    });
  }

  void moveLeft() {
    if (isDead) return;
    animateRun();
    setState(() {
      marioX = (marioX - 0.06).clamp(-1.0, 1.0);
      facingRight = false;
    });
    _checkCollision();
  }

  void moveRight() {
    if (isDead) return;
    animateRun();
    setState(() {
      marioX = (marioX + 0.06).clamp(-1.0, 1.0);
      facingRight = true;
    });
    _checkCollision();
  }

  void startJump() {
    if (isDead || isJumping) return;
    isJumping = true;
    jumpTime = 0;
    initialY = marioY;

    jumpTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      jumpTime += 0.03;
      final velocity = -4.9 * jumpTime * jumpTime + 5 * jumpTime;
      final newY = initialY - velocity;

      setState(() {
        marioY = newY.clamp(-1.0, 1.0);
      });

      if (marioY >= 1) {
        setState(() {
          marioY = 1;
          isJumping = false;
        });
        timer.cancel();
      }

      _checkCollision();
    });
  }

  void _checkCollision() {
    if (isDead) return;
    for (final obstacleX in obstaclePositions) {
      final diffX = (marioX - obstacleX).abs();
      final isOnGround = marioY > 0.85;
      if (diffX < 0.08 && isOnGround) {
        setState(() {
          isDead = true;
          statusText = 'Game Over! Tap restart';
        });
        jumpTimer?.cancel();
        runTimer?.cancel();
        return;
      }
    }
  }

  @override
  void dispose() {
    jumpTimer?.cancel();
    runTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.lightBlue.shade400,
              child: Stack(
                children: [
                  // Clouds
                  Align(
                    alignment: const Alignment(-0.8, -0.6),
                    child: SizedBox(
                      width: 180,
                      height: 120,
                      child: Image.asset('lib/images/cloud.png', fit: BoxFit.contain),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.5, -0.4),
                    child: SizedBox(
                      width: 160,
                      height: 100,
                      child: Image.asset('lib/images/cloud.png', fit: BoxFit.contain),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(-0.3, -0.7),
                    child: SizedBox(
                      width: 200,
                      height: 130,
                      child: Image.asset('lib/images/cloud.png', fit: BoxFit.contain),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.8, -0.5),
                    child: SizedBox(
                      width: 190,
                      height: 130,
                      child: Image.asset('lib/images/cloud.png', fit: BoxFit.contain),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.0, -0.85),
                    child: SizedBox(
                      width: 220,
                      height: 140,
                      child: Image.asset('lib/images/cloud.png', fit: BoxFit.contain),
                    ),
                  ),

                  Align(
                    alignment: const Alignment(0, 1),
                    child: Container(
                      height: 100,
                      color: Colors.brown,
                    ),
                  ),

                  // Obstacles
                  for (final obstacleX in obstaclePositions)
                    Align(
                      alignment: Alignment(obstacleX, 0.8),
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: Image.asset('lib/images/hurdle.png', fit: BoxFit.contain),
                      ),
                    ),

                  // Mario
                  Align(
                    alignment: Alignment(marioX, marioY),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(facingRight ? 1.0 : -1.0, 1.0, 1.0),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.asset(isRunning ? 'lib/images/move.png' : 'lib/images/stop.png'),
                      ),
                    ),
                  ),

                  // Game over text
                  if (isDead)
                    const Align(
                      alignment: Alignment(0, -0.2),
                      child: Text(
                        'GAME OVER',
                        style: TextStyle(
                          fontSize: 38,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                        ),
                      ),
                    ),

                  Align(
                    alignment: const Alignment(0, -0.95),
                    child: Text(
                      statusText,
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.brown.shade700,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyButton(
                        onTap: moveLeft,
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      MyButton(
                        onTap: startJump,
                        child: const Icon(Icons.arrow_upward, color: Colors.white),
                      ),
                      MyButton(
                        onTap: moveRight,
                        child: const Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                    ],
                  ),
                  MyButton(
                    onTap: resetGame,
                    child: const Text('Restart', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}