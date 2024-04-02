import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';

void main() {
  runApp(SnakeGame());
}

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Snake(),
      ),
    );
  }
}

class Snake extends StatefulWidget {
  @override
  _SnakeState createState() => _SnakeState();
}

class _SnakeState extends State<Snake> {
  static const int gridSize = 20;
  static const int cellSize = 20;
  static const int speed = 150;

  var snakePosition = [
    Point(gridSize ~/ 2, gridSize ~/ 2),
    Point(gridSize ~/ 2 - 1, gridSize ~/ 2),
    Point(gridSize ~/ 2 - 2, gridSize ~/ 2),
  ];

  Point food = Point(0, 0); // Initialize with a default value
  var direction = 'RIGHT';
  bool gameStarted = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    startGame();
    // Listen to keyboard events
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp && direction != 'DOWN') {
        direction = 'UP';
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown && direction != 'UP') {
        direction = 'DOWN';
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && direction != 'RIGHT') {
        direction = 'LEFT';
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight && direction != 'LEFT') {
        direction = 'RIGHT';
      }
    }
  }

  void startGame() {
    createFood();
    gameStarted = true;
    Timer.periodic(Duration(milliseconds: speed), (Timer timer) {
      if (!gameStarted) {
        timer.cancel();
        return;
      }
      moveSnake();
      if (checkCollision()) {
        timer.cancel();
        gameOver();
      }
    });
  }

  void moveSnake() {
    setState(() {
      var newHead;
      switch (direction) {
        case 'UP':
          newHead = Point(snakePosition.first.x, snakePosition.first.y - 1);
          break;
        case 'DOWN':
          newHead = Point(snakePosition.first.x, snakePosition.first.y + 1);
          break;
        case 'LEFT':
          newHead = Point(snakePosition.first.x - 1, snakePosition.first.y);
          break;
        case 'RIGHT':
          newHead = Point(snakePosition.first.x + 1, snakePosition.first.y);
          break;
      }
      snakePosition.insert(0, newHead);
      if (newHead == food) {
        createFood();
        score++; // Increment score
      } else {
        snakePosition.removeLast();
      }
    });
  }

  bool checkCollision() {
    if (snakePosition.first.x <= 0 ||
        snakePosition.first.y <= 0 ||
        snakePosition.first.x >= gridSize - 1 ||
        snakePosition.first.y >= gridSize - 1) {
      return true;
    }
    for (var i = 1; i < snakePosition.length; i++) {
      if (snakePosition[i] == snakePosition.first) {
        return true;
      }
    }
    return false;
  }

  void createFood() {
    var random = Random();
    int x = random.nextInt(gridSize - 2) + 1;
    int y = random.nextInt(gridSize - 2) + 1;
    food = Point(x, y);
  }

  void gameOver() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('You lost. Your score: $score\nWould you like to play again?'),
          actions: [
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                setState(() {
                  snakePosition = [
                    Point(gridSize ~/ 2, gridSize ~/ 2),
                    Point(gridSize ~/ 2 - 1, gridSize ~/ 2),
                    Point(gridSize ~/ 2 - 2, gridSize ~/ 2),
                  ];
                  gameStarted = false;
                  score = 0; // Reset score
                  startGame();
                  Navigator.of(context).pop();
                });
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  gameStarted = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game - Score: $score'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[800],
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: gridSize * gridSize,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                ),
                itemBuilder: (BuildContext context, int index) {
                  var color = Colors.grey[850];
                  var x = index % gridSize;
                  var y = index ~/ gridSize;
                  var point = Point(x, y);
                  if (snakePosition.contains(point)) {
                    color = Colors.green;
                  }
                  if (food == point) {
                    color = Colors.red;
                  }
                  return Container(
                    margin: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
