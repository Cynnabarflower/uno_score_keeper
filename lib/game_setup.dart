import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uno_score_keeper/add_player.dart';
import 'package:uno_score_keeper/player.dart';
import 'package:uno_score_keeper/reward_screen.dart';

import 'game.dart';
import 'main.dart';

class GameSetup extends StatefulWidget {
  @override
  State createState() => _GameSetupState();
}

class _GameSetupState extends State<GameSetup> with SingleTickerProviderStateMixin {
  List<Player> players = [];
  int maxScore = 100;
  TabController switcherController;
  ScrollController scrollController;


  @override
  void initState() {
    scrollController = new ScrollController();
    switcherController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var s = MediaQuery.of(context).size;

    print(s);

    if (s.width < MIN_WIDTH || s.height < MIN_HEIGHT) {
      return smallScreen(context);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constrains) {

          bool canPlay = maxScore > 0 && players.isNotEmpty;
          Function startSetState;
          return frame(context, constrains, child: LayoutBuilder(
            builder: (context, constraints2) {
              s = constraints2.biggest;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: s.aspectRatio < 5/3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          'Uno Score Keeper',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  s.aspectRatio < 5/3 ?
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                        mySwitcher(
                            ['First to lose', 'Original'],
                                (index){print(index);}),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: maxScoreWidget(startSetState),
                      ),
                    ],
                  ) :
                  Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: mySwitcher(
                              ['First to lose', 'Original'],
                                  (index){print(index);}),
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: maxScoreWidget(startSetState),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: s.aspectRatio < 5/3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          'Players',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                        controller: scrollController,
                        children: [
                          ...players
                              .map((e) => Padding(
                            padding: const EdgeInsets
                                .symmetric(
                                vertical: 4,
                                horizontal: 8),
                            child:
                            getPlayerButton(e),
                          ))
                              .toList(),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddPlayer(players)),
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    players.add(value);
                                  });
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 4),
                              child: Container(
                                height: 50,
                                alignment: Alignment.center,
                                margin: new EdgeInsets.only(left: 24.0, top: 8),
                                decoration: new BoxDecoration(
                                  color: Theme.of(context).buttonColor,
                                  shape: BoxShape.rectangle,
                                  borderRadius: new BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: FittedBox(
                                    fit: BoxFit.fitHeight,
                                    child: Text(
                                      '+',
                                      style: TextStyle(color: Colors.white, fontSize: 50),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ]
                    ),
                  ),
                  StatefulBuilder(
                      builder: (context, setState) {
                        startSetState = setState;
                        return Row(
                          children: [
                            InkWell(
                              onTap: () {Navigator.of(context).pop();},
                              child: Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.center,
                                margin: new EdgeInsets.only(left: 0.0, top: 8, right: 2.0),
                                decoration: new BoxDecoration(
                                  color: Theme.of(context).buttonColor,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(8)
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: FittedBox(
                                    fit: BoxFit.fitHeight,
                                    child: Icon(Icons.arrow_back_outlined, color: Colors.white, size: 12),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: players.length > 1 ? () {
                                  players.forEach((element) {element.score = 0;});
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Game(players,
                                                maxScore,
                                                switcherController.index == 0
                                                    ? GameVariant.firstToLose : GameVariant.original)),
                                  );
                                } : null,
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  margin: new EdgeInsets.only(left: 0.0, top: 8),
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).buttonColor.withOpacity(canPlay ? 1.0 : 0.7),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(8)
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: FittedBox(
                                      fit: BoxFit.fitHeight,
                                      child: Text(
                                        'Start',
                                        style: TextStyle(color: Colors.white.withOpacity(canPlay ? 1.0 : 0.7), fontSize: 50),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                  )
                ]);},
          ));
        }),
      ),
    );
  }


  @override
  void dispose() {
    switcherController?.dispose();
    super.dispose();
  }

  Widget getPlayerButton(Player player, {textColor = Colors.white}) {
    var playerThumbnail = new Container(
      alignment: FractionalOffset.centerLeft,
      child: ClipOval(
        child: new Image(
          image: player.icon,
          height: 48.0,
          width: 48.0,
        ),
      ),
    );

    final planetCard = Container(
      alignment: Alignment.center,
      margin: new EdgeInsets.only(left: 24.0),
      decoration: new BoxDecoration(
        color: Theme.of(context).buttonColor,
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: new Offset(0.0, 6.0),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            player.name,
            style: TextStyle(color: textColor, fontSize: 50),
          ),
        ),
      ),
    );

    return InkWell(
      onTap: null,
      child: new Container(
          height: 50.0,
          margin: const EdgeInsets.symmetric(
            vertical: 6.0,
          ),
          child:  Dismissible(
            direction: DismissDirection.endToStart,
              key: Key(player.id),
              onDismissed: (direction) {
                players.removeWhere((element) => element == player);
                setState(() {});
              },
              background: Container(
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 24),
                decoration: new BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.rectangle,
                  borderRadius: new BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text("Delete",textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.delete, color: Colors.white))
                    ],
                  ),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  planetCard,
                  playerThumbnail,
                ],
              )
          )
      ),
    );
  }

  Widget getGameButton(text, image, pressed, color,
      {textColor = Colors.white}) {
    var blur = 0.5;

    var planetThumbnail = new Container(
      alignment: FractionalOffset.centerLeft,
      child: ClipOval(
        child: new Image(
          image: AssetImage('assets/images/' + image),
          height: 48.0,
          width: 48.0,
        ),
      ),
    );

    final planetCard = new Container(
      alignment: Alignment.center,
      margin: new EdgeInsets.only(left: 24.0),
      decoration: new BoxDecoration(
        color: Theme.of(context).buttonColor,
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            offset: new Offset(0.0, 6.0),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 50),
          ),
        ),
      ),
    );

    return InkWell(
      onTap: pressed,
      child: new Container(
          height: 70.0,
          margin: const EdgeInsets.symmetric(
            vertical: 12.0,
          ),
          child: new Stack(
            children: <Widget>[
              planetCard,
              planetThumbnail,
            ],
          )),
    );
  }

  Widget mySwitcher(List variants, callback) {

    switcherController.addListener(() {callback(switcherController.index);});

    return TabBar(
      unselectedLabelColor: Colors.white,
      labelColor: Colors.black,
      labelPadding: EdgeInsets.all(8.0),
      tabs: [
        ...variants.map((e) => Center(child: Text(e, style: TextStyle(
            fontSize: 15.0, fontWeight: FontWeight.w600),)))
      ],
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      controller: switcherController,
    );
  }

  Widget maxScoreWidget(startSetState) {
    var controller = TextEditingController()
      ..text = maxScore.toString();
    return Container(
      width: 400,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: GestureDetector(
                onTap: (){
                  maxScore-=10;
                  maxScore = max(maxScore, 0);
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
          Expanded(
            child: TextField(
              controller: controller,
            onChanged: (value) {
                int a = int.tryParse(value);
              if (value.isNotEmpty && (a == null || a < 0)) {
                controller.text = maxScore.toString();
              } else {
                maxScore = a ?? 0;
              }
              startSetState((){});
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
          Expanded(
            child: GestureDetector(
              onTap: (){
                maxScore+=10;
                maxScore = min(maxScore, 9999);
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
          )
        ],
      ),
    );
  }

}
