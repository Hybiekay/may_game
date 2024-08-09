import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttergame/firebase_options.dart';
import 'package:fluttergame/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: 'AIzaSyAXOGrWv5hMr4_huabO1O7NOzHfgMvBnZI',
    appId: '1:578964763408:android:1dd174d8ec2895a2e72b95',
    messagingSenderId: '578964763408',
    projectId: 'flutter-game-may',
    storageBucket: 'flutter-game-may.appspot.com',
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: GameHome(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String status = "You turn";
  int player = 1;
  int computer = 2;
  List<int> board = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  int time = 60;
  int winning = 0;
  int coin = 0;
  int computerWinning = 0;
  Timer? timer;

  startTiming() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (time > 0) {
        setState(() {
          time--;
        });
      } else {
        t.cancel();
        timer?.cancel();
        if (winning != 5) {
          showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.red.withOpacity(0.5),
              builder: (context) {
                return AlertDialog(
                  title: Text("You Lost"),
                  actions: [
                    Container(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            board = List.filled(9, 0);
                            winning = 0;
                            computerWinning = 0;
                            time = 60;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Restart",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GameHome()));
                        },
                        child: Text(
                          "End Game",
                          style: TextStyle(color: Colors.amber),
                        ),
                      ),
                    )
                  ],
                );
              });
        } else {
          showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.green.withOpacity(0.5),
              builder: (c) {
                return AlertDialog(
                  title: Text("You Won"),
                  actions: [
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber),
                        onPressed: () {
                          setState(() {
                            board = List.filled(9, 0);
                            time = 60;
                            winning = 0;
                            computerWinning = 0;
                          });
                          startTiming();
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Play Again ",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GameHome()));
                        },
                        child: Text(
                          "Ends Game",
                          style: TextStyle(color: Colors.amber),
                        ),
                      ),
                    )
                  ],
                );
              });
        }
      }
    });
  }

  Future runComputer() async {
    /// first
    if (board.every((one) => one != 0) && time > 2) {
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          board = List.filled(9, 0);
        });
      });
    }

    /// second
    if (isWinner(player, board)) {
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          winning++;
          board = List.filled(9, 0);
          coin += 30;
        });

//third
      });
    }

    if (winning == 5) {
      timer?.cancel();
      showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.green.withOpacity(0.5),
          builder: (c) {
            return AlertDialog(
              title: Text("You Won"),
              actions: [
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: () {
                      setState(() {
                        board = List.filled(9, 0);
                        time = 60;
                        winning = 0;
                        computerWinning = 0;
                      });
                      startTiming();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Play Again ",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => GameHome()));
                    },
                    child: Text(
                      "Ends Game",
                      style: TextStyle(color: Colors.amber),
                    ),
                  ),
                )
              ],
            );
          });
    } else {
      await Future.delayed(Duration(milliseconds: 300), () {
        int? blockingMove;
        int? winingMove;
        List<int> avaliableMove = [];

        for (int i = 0; i < board.length; i++) {
          if (board[i] != 0) {
            continue;
          }
          List<int> demoBoard = List.from(board);
          demoBoard[i] = player;
          if (isWinner(player, demoBoard)) {
            blockingMove = i;
          }
          demoBoard[i] = computer;
          if (isWinner(computer, demoBoard)) {
            winingMove = i;
          }

          avaliableMove.add(i);
        }

        if (winingMove != null) {
          makeMove(winingMove);
        } else if (blockingMove != null) {
          makeMove(blockingMove);
        } else {
          if (avaliableMove.isNotEmpty) {
            var random = Random();
            var randomIdex = random.nextInt(avaliableMove.length);
            var randomMove = avaliableMove[randomIdex];

            makeMove(randomMove);
          }
        }
      });
    }
  }

  makeMove(int move) {
    setState(() {
      board[move] = computer;
    });

    if (isWinner(computer, board)) {
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          computerWinning++;
          board = List.filled(9, 0);
        });
        if (computerWinning >= 5) {
          showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.red.withOpacity(0.5),
              builder: (context) {
                return AlertDialog(
                  title: Text("You Lost"),
                  actions: [
                    Container(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            board = List.filled(9, 0);
                            winning = 0;
                            computerWinning = 0;
                            time = 60;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Restart",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const GameHome()));
                        },
                        child: Text(
                          "End Game",
                          style: TextStyle(color: Colors.amber),
                        ),
                      ),
                    )
                  ],
                );
              });
        }
      });
    }

    if (board.every((element) => element != 0) && time > 2) {
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          board = List.filled(9, 0);
        });
      });
    }
  }

  bool isWinner(int who, List<int> board) {
    //012
    //345
    //678
    //036
    //147
    //258
    //048
    //246
    return (board[0] == who && board[1] == who && board[2] == who) ||
        (board[3] == who && board[4] == who && board[5] == who) ||
        (board[6] == who && board[7] == who && board[8] == who) ||
        (board[0] == who && board[3] == who && board[6] == who) ||
        (board[1] == who && board[4] == who && board[7] == who) ||
        (board[2] == who && board[5] == who && board[8] == who) ||
        (board[0] == who && board[4] == who && board[8] == who) ||
        (board[2] == who && board[4] == who && board[6] == who);
  }

  //   bool isWinning(int who, List<int> games) {
  //   return games[0] == who && games[1] == who && games[2] == who || // row
  //       games[3] == who && games[4] == who && games[5] == who || // row
  //       games[6] == who && games[7] == who && games[8] == who || // row
  //       games[0] == who && games[3] == who && games[6] == who || // colunm
  //       games[1] == who && games[4] == who && games[7] == who || //colunm
  //       games[2] == who && games[5] == who && games[8] == who || //colum
  //       games[0] == who && games[4] == who && games[8] == who || // diaganal
  //       games[2] == who && games[4] == who && games[6] == who; //
  // }

  @override
  void initState() {
    startTiming();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: [
            Text(time.toString()),
            SizedBox(
              width: 10,
            ),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: "P: $winning",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                TextSpan(
                  text: "/",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                TextSpan(
                  text: " C: $computerWinning",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                )
              ]),
            )
          ],
        ),
        actions: [
          Image(
            image: AssetImage("assets/images/coin.png"),
            height: 50,
            width: 50,
          ),
          Text(
            "$coin",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  board = List.filled(9, 0);
                  status = "Play";
                  time = 60;
                  winning = 0;
                  computerWinning = 0;
                });
                startTiming();
              },
              icon: Icon(
                Icons.restart_alt_rounded,
                size: 30,
              )),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
              height: 420,
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  for (int i = 0; i < board.length; i++)
                    GestureDetector(
                      onTap: () async {
                        if (board[i] != 0) {
                          setState(() {
                            board[i] == player
                                ? status = "You have already played here"
                                : status = "Opponent has played here already";
                          });
                        } else {
                          setState(() {
                            board[i] = player;
                            status = "Computer Turn";
                          });
                          await runComputer();
                          setState(() {
                            status = "Your Turn";
                          });
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: board[i] == player
                              ? Colors.green
                              : board[i] == computer
                                  ? Colors.amber
                                  : Colors.amber.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          board[i] == player
                              ? "X"
                              : board[i] == computer
                                  ? "O"
                                  : "",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                ],
              )),
          SizedBox(
            height: 50,
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
