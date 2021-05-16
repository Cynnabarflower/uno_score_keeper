import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_score_keeper/player.dart';
import 'package:uno_score_keeper/reward_screen.dart';

import 'main.dart';

enum GameVariant {
  original,
  firstToLose
}

class Game extends StatefulWidget {

  List<Player> players;
  int maxScore = 0;
  GameVariant gameVariant;
  GlobalKey<_GameState> key;
  SharedPreferences sharedPreferences;
  Map<Player, List<int>> scores = Map();

  Game(this.players, this.maxScore, this.gameVariant) {
    for (var p in players) {
      scores[p] = [];
    }
  }

  static Future<Game> load() async {
    Game game = Game([], 0, GameVariant.original);
    if (await game.loadGame())
      return game;
    return null;
  }


  Future<bool> loadGame() async {
    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
    }
    try {
      List<String> savedScores = sharedPreferences.getStringList('game');
      if (savedScores == null)
        return false;
      var gamePreferences = savedScores[0].split(';');
      for (var g in GameVariant.values) {
        if (g.toString() == gamePreferences[0]) {
          gameVariant = g;
          break;
        }
      }
      maxScore = 0;

      maxScore = int.parse(gamePreferences[1]);
      var savedPlayers = sharedPreferences.getStringList('players');
      Player player;
      for (var s in savedScores.sublist(1)) {
        var tokens = s.split(';');
        String playerString = savedPlayers.firstWhere((element) =>
            element.startsWith(tokens[0]), orElse: () => null,);
        if (playerString == null)
          return false;
        var playerTokens = playerString.split(';');
        player = Player(
            playerTokens[1], id: playerTokens[0], assetPath: playerTokens[2]);
        scores[player] = [];
        players.add(player);
        for (var t in tokens.sublist(1)) {
          scores[player].add(int.parse(t));
        }
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static void deleteSaved() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('game');
  }

  void saveGame() async {
    List<String> saveStrings = ['${gameVariant.toString()};${maxScore}'];
    for (var p in scores.keys) {
      saveStrings.add(scores[p].fold(p.id, (previousValue, element) => previousValue+';'+element.toString()));
    }
    if (sharedPreferences == null)
      sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList('game', saveStrings);
    print('Game saved');
  }


  @override
  State createState() => _GameState();
}

class _GameState extends State<Game> {

  LinkedScrollControllerGroup scrollControllerGroup;
  List<ScrollController> controllers = [];

  @override
  Widget build(BuildContext context) {
    var s = MediaQuery.of(context).size;


    var t = [];
    List<int> arr = [];
    arr.length;
    arr.sort((a,b) => a-b);
    print(s);
    String ss = "123";

    int.parse(ss, radix: 10);
    

    if (s.width < MIN_WIDTH || s.height < MIN_HEIGHT) {
      return smallScreen(context);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          color: Theme.of(context).backgroundColor,
          child: LayoutBuilder(builder: (context, constrains) {
            return frame(
              context, constrains,
              fixed: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  s = constraints.biggest;
                return Stack(
                  children: [
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                '${widget.gameVariant == GameVariant.firstToLose
                                    ? 'First to lose' : 'Original'} ${widget.maxScore}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: s.aspectRatio < 5/3 ? 50 : 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                                builder: (context, constrains) {
                                  var playerRowHeight = 0.0;
                                  Axis axis = Axis.horizontal;
                                  if (constrains.biggest.aspectRatio > 1) {
                                    playerRowHeight = max(constrains.maxHeight / 6, 80);
                                    axis = Axis.vertical;
                                  } else {
                                    playerRowHeight = max(constrains.maxWidth / 4, 80);
                                  }

                                  int rowIndex = 0;
                                  var playerRows = widget.scores.keys.map((e) => playerRow(e, widget.scores[e], playerRowHeight, controllers[rowIndex++],axis: axis == Axis.horizontal ? Axis.vertical : Axis.horizontal));

                                  return ListView(
                                      scrollDirection: axis,
                                      children: [
                                        ...playerRows
                                      ]
                                  );
                                }
                            ),
                          )

                        ]),
                       Align(
                         alignment: Alignment.bottomRight,
                         child: Padding(
                           padding: EdgeInsets.all(16),
                           child: Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Container(
                                   height: 60,
                                   width: 60,
                                   child: GestureDetector(
                                     onTap: () {
                                       widget.saveGame();
                                       Navigator.of(context).pop();
                                     },
                                     child:  Container(
                                         padding: EdgeInsets.all(4),
                                         child: FittedBox(
                                           fit: BoxFit.fitWidth,
                                           child: Column(
                                             children: [
                                               Icon(Icons.arrow_back_rounded, color: Colors.white, size:30),
                                               Text('Exit and save', style: TextStyle(color: Colors.white70),)
                                             ],
                                           ),
                                         ),
                                         decoration: BoxDecoration(
                                             borderRadius: BorderRadius.all(Radius.circular(8))
                                         )
                                     ),
                                   )
                               ),
                               Container(
                                   height: 60,
                                   width: 60,
                                   child: getAddButton(context)
                               ),
                             ],
                           ),
                         ),
                       )
                  ],
                );},
              )
            );
          }),
        ),
      ),
    );
  }

  Widget getAddButton(context) {
    return  GestureDetector(
        onTap: () {
          int addScore = 0;
          Future showPlayerBottomSheet(playerName) async {
          return showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (BuildContext bc){
                var controller = TextEditingController()
                  ..text = addScore.toString();
                Function saveSetState;
                return StatefulBuilder(
                  builder: (context, setState) {
                    controller.text = addScore.toString();
                    return Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).buttonColor,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 16, bottom: 8),
                            child: Text(
                              playerName,
                              style:  TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          Container(
                            width: 400,
                            padding: EdgeInsets.only(left: 8, right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Visibility(
                                    visible: false,
                                    child: GestureDetector(
                                      onTap: (){
                                        addScore-=10;
                                        addScore = max(addScore, 0);
                                        setState(() {});
                                      },
                                      child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context).buttonColor,
                                              borderRadius: BorderRadius.horizontal(left: Radius.circular(8))
                                          ),
                                          height: 50,
                                          child: Icon(Icons.remove, color: Colors.white,)
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    color: Colors.lightBlue,
                                    child: TextField(
                                      controller: controller,
                                      onChanged: (value) {
                                        int a = int.tryParse(value);
                                        if (value.isNotEmpty && (a == null || a < 0)) {
                                          controller.text = addScore.toString();
                                        } else {
                                          addScore = a ?? 0;
                                        }
                                        saveSetState((){});
                                      },
                                      onSubmitted: (value) {
                                        Navigator.pop(context, addScore);
                                      },
                                      showCursor: false,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          counterText: ""
                                      ),
                                      maxLength: 4,

                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontSize: 42),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Visibility(
                                    visible: false,
                                    child: GestureDetector(
                                      onTap: (){
                                        addScore+=10;
                                        addScore = min(addScore, 9999);
                                        setState(() {});
                                      },
                                      child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context).buttonColor,
                                              borderRadius: BorderRadius.horizontal(right: Radius.circular(8))
                                          ),
                                          height: 50,
                                          child: Icon(Icons.add, color: Colors.white,)
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          StatefulBuilder(
                              builder: (context, setState) {
                                saveSetState = setState;
                                return InkWell(
                                  onTap: addScore > 0 ? (){
                                    Navigator.of(context).pop(addScore);
                                  } : null,
                                  child: Container(
                                    height: 50,
                                    alignment: Alignment.center,
                                    margin: new EdgeInsets.only(left: 0.0, top: 8),
                                    decoration: new BoxDecoration(
                                      color: Theme.of(context).buttonColor.withOpacity(addScore > 0 ? 1.0 : 0.7),
                                      shape: BoxShape.rectangle,
                                      borderRadius: new BorderRadius.circular(8.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: FittedBox(
                                        fit: BoxFit.fitHeight,
                                        child: Text(
                                          'Done',
                                          style: TextStyle(color: Colors.white.withOpacity(addScore > 0 ? 1.0 : 0.7), fontSize: 50),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                          )
                        ],
                      ),
                    );
                  },
                );
              }
          );}
          for (var p in  widget.scores.keys.toList().reversed) {
            showPlayerBottomSheet(p.name).then((value) {
              value = value ?? 0;
              if (value != null) {
                p.score += value;
                widget.scores[p].add(value);
                if (!isGameFinished()) {
                  widget.saveGame();
                  setState(() {});
                } else {
                  Game.deleteSaved();
                  Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => RewardScreen(widget.players, widget.maxScore, widget.gameVariant)));
                }
              }
            });
          }
        },
        child: Container(
            child: Icon(Icons.add, color: Colors.white, size:60),
            decoration: BoxDecoration(
              color: Theme.of(context).buttonColor,
              shape: BoxShape.circle,
            )
        )
    );
  }

  bool isGameFinished() {
    var len = widget.scores.values.fold(0, (p, e) => e.length > p ? e.length : p);
    for (var p in widget.scores.keys) {
      if (p.score < widget.maxScore && widget.scores[p].length < len)
        return false;
    }

    List <Player> players = widget.scores.keys.toList()..sort((a,b) => a.score - b.score);
    if (players.last.score >= widget.maxScore) {
      if (widget.gameVariant == GameVariant.firstToLose) {
        var maxSum = players.last.score;
        List<Player> loosers = [];
        for (var p in players.reversed) {
          if (p.score == maxSum) {
            loosers.add(p);
          } else {
            break;
          }
        }
      } else {
        int minSum = players.first.score;
        List<Player> winners = [];
        for (var p in players) {
          if (p.score == minSum) {
            winners.add(p);
          } else {
            break;
          }
        }
      }



      return true;
    }
    return false;

  }

  Widget playerRow(Player player, List playerScores, height, controller, {axis : Axis.horizontal}) {
    int sum = 0;

    Widget roundPart(e) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text((sum+=e).toString(), style: TextStyle(color: Colors.white, fontSize: 30),),
          Text("+${e}", style: TextStyle(color: Colors.white, fontSize: 20),)
        ],
      );
    }

    Widget addButton = GestureDetector(
      onTap: () {
        int addScore = 0;
          showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (BuildContext bc){
                var controller = TextEditingController()
                  ..text = addScore.toString();
                Function saveSetState;
                return StatefulBuilder(
                  builder: (context, setState) {
                    controller.text = addScore.toString();
                    return Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).buttonColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 400,
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Visibility(
                                  visible: false,
                                  child: GestureDetector(
                                    onTap: (){
                                      addScore-=10;
                                      addScore = max(addScore, 0);
                                      setState(() {});
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).buttonColor,
                                            borderRadius: BorderRadius.horizontal(left: Radius.circular(8))
                                        ),
                                        height: 50,
                                        child: Icon(Icons.remove, color: Colors.white,)
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: Colors.lightBlue,
                                  child: TextField(
                                    controller: controller,
                                    onChanged: (value) {
                                      int a = int.tryParse(value);
                                      if (value.isNotEmpty && (a == null || a < 0)) {
                                        controller.text = addScore.toString();
                                      } else {
                                        addScore = a ?? 0;
                                      }
                                      saveSetState((){});
                                    },
                                    showCursor: false,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        counterText: ""
                                    ),
                                    maxLength: 4,

                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: 42),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Visibility(
                                  visible: false,
                                  child: GestureDetector(
                                    onTap: (){
                                      addScore+=10;
                                      addScore = min(addScore, 9999);
                                      setState(() {});
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).buttonColor,
                                            borderRadius: BorderRadius.horizontal(right: Radius.circular(8))
                                        ),
                                        height: 50,
                                        child: Icon(Icons.add, color: Colors.white,)
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        StatefulBuilder(
                            builder: (context, setState) {
                              saveSetState = setState;
                              return InkWell(
                                onTap: addScore > 0 ? (){
                                  Navigator.of(context).pop(addScore);
                                } : null,
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  margin: new EdgeInsets.only(left: 0.0, top: 8),
                                  decoration: new BoxDecoration(
                                      color: Theme.of(context).buttonColor.withOpacity(addScore > 0 ? 1.0 : 0.7),
                                    shape: BoxShape.rectangle,
                                    borderRadius: new BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: FittedBox(
                                      fit: BoxFit.fitHeight,
                                      child: Text(
                                        'Done',
                                        style: TextStyle(color: Colors.white.withOpacity(addScore > 0 ? 1.0 : 0.7), fontSize: 50),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                        )
                      ],
                    ),
                  );
                    },
                );
              }
              ).then((value) {
            if (value != null) {
              player.score += value;
              playerScores.add(value);
              if (!isGameFinished()) {
                widget.saveGame();
                setState(() {});
              } else {
                Game.deleteSaved();
                Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => RewardScreen(widget.players, widget.maxScore, widget.gameVariant)));
              }
            }
          });
      },
        child: Container(
            child: Icon(Icons.add, color: Colors.white, size: height/4),
            decoration: BoxDecoration(
              color: Theme.of(context).buttonColor,
              shape: BoxShape.circle,
            )
        )
    );

    var scoresPart = SingleChildScrollView(
      scrollDirection: axis,
      controller: controller,
      reverse: true,
      child: axis == Axis.horizontal ? Row(
        children: [
          ...playerScores.map((e) => Container(
            height: height,
            width: 80,
            child: roundPart(e),
          )),
       /*   Container(
              height: height/2,
              width: 80,
              child: addButton)*/
        ],
      ) : Column(
        children: [
          ...playerScores.map((e) => Container(
            width: height,
            height: 80,
            child: roundPart(e),
          )),
       /*   Container(
              height: 80,
              width: height/2,
              child: addButton)*/
        ],
      ),
    );

    var playerWidget = Container(
      padding: EdgeInsets.only(bottom: 8, right: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image(width: height*0.5, image: player.icon,),
          ),
          Text(player.name, style: TextStyle(color: Colors.white))
        ],
      ),
    );

    if (axis == Axis.horizontal) {
      return Container(
        width: 80,
        child: Row(
          children: [
            playerWidget,
            Expanded(child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: scoresPart,
            ))
          ],
        ),
      );
    } else {
      return Container(
        width: height,
        child: Column(
          children: [
            playerWidget,
            Expanded(child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: scoresPart,
            ))
          ],
        ),
      );
    }
  }


  @override
  void initState() {
    scrollControllerGroup = LinkedScrollControllerGroup();
    for (var p in widget.players) {
      controllers.add(scrollControllerGroup.addAndGet());
    }


    super.initState();
  }
}