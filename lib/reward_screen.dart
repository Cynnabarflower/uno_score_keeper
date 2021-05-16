import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:uno_score_keeper/player.dart';

import 'game.dart';
import 'main.dart';

class RewardScreen extends StatefulWidget {

  List<Player> players;
  int maxScore = 0;
  GameVariant gameVariant;

  RewardScreen(this.players, this.maxScore, this.gameVariant) {
    this.players.sort((a,b) => a.score - b.score);
  }

  @override
  State createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {

  @override
  Widget build(BuildContext context) {
    var s = MediaQuery.of(context).size;

    print(s);
    int place = 1;
    if (s.width < MIN_WIDTH || s.height < MIN_HEIGHT) {
      return smallScreen(context);
    }

    bool horizontal = s.aspectRatio > 4/3;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: LayoutBuilder(builder: (context, constrains) {
            return frame(context, constrains,
            fixed: false,
            child: horizontal ?
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                      flex: 2,
                      child: Center(child: nameAndWinner(min(constrains.maxWidth / 4 * 2/5, constrains.maxHeight / 3)))),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4, right: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: ListView(
                          children: [
                            ...widget.players.map((e) => playerRow(e, place++))
                          ],
                        ),
                      ),
                    ),
                  )
                ])
                :
            Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  nameAndWinner(min(constrains.maxWidth / 4, constrains.maxHeight / 3)),
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  Flexible(
                    flex: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16, left: 2, right: 2),
                        child: ListView(
                          children: [
                            ...widget.players.map((e) => playerRow(e, place++))
                          ],
                        ),
                      ),
                    ),
                  )
                ])
            );
          }),
        ),
      ),
    );
  }

  Widget nameAndWinner(double winnerWidth) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Stack(
              children: [
                Text(
                  '${widget.gameVariant == GameVariant.firstToLose
                      ? 'First to lose' : 'Original'} ${widget.maxScore}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        winnerWidget(
            winnerWidth
        ),
      ],
    );
  }

  Widget winnerWidget(winnerSize) {

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
           widget.players.length >= 3
               ? topPlayerIcon(winnerSize * 0.8, Colors.orangeAccent[200], widget.players[2], edgeInsets: EdgeInsets.only(left: winnerSize*3/2, top: winnerSize/4))
            : Container(),
            widget.players.length >= 2
                ? topPlayerIcon(winnerSize * 0.9, Colors.grey[300], widget.players[1], edgeInsets: EdgeInsets.only(right: winnerSize*3/2, top: winnerSize/4))
            : Container(),
            widget.players.isNotEmpty ?
            topPlayerIcon(winnerSize, Colors.yellow, widget.players.first)
                : Container()
          ],
        );
      },
    );
  }

  Widget topPlayerIcon(double winnerSize, Color color, Player player, {EdgeInsets edgeInsets = EdgeInsets.zero}) {
   return Padding(
     padding: edgeInsets,
     child: Stack(
       alignment: Alignment.center,
        children: [
          Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 4
                  )
                ]
              ),
              padding: EdgeInsets.all(8),
              child: Image(image: player.icon, width: winnerSize)),
          Container(
            width: winnerSize * 0.6,
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: winnerSize*1.05),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(winnerSize/40))
              ),
              padding: EdgeInsets.symmetric(vertical: winnerSize/40, horizontal: winnerSize/20),
              child: FittedBox(
                alignment: Alignment.center,
                fit: BoxFit.fitWidth,
                child: Text(
                  player.name,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 9999, shadows: [Shadow(offset: Offset(2,2),blurRadius: 3)]),
                ),
              ),
            ),
          )
        ],
      ),
   );
  }

  Widget playerRow(Player player, int place) {
    return Container(
      height: 50,
      color: Colors.white24,
      padding: const EdgeInsets.only(top: 4.0, left: 4, bottom: 4, right: 8),
      margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: place == 1 ? Colors.yellow : place == 2 ? Colors.grey[300] : place == 3 ? Colors.orangeAccent[200] : Colors.transparent,
                  alignment: Alignment.center,
                  child: FittedBox(
                    alignment: Alignment.center,
                    fit: BoxFit.fill,
                    child: Text(
                      '$place',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 4)], fontSize: 999),
                    ),
                  ),
                ),
              ),
              VerticalDivider(
                color: Colors.black12,
                thickness: 1,
              ),
              Padding(
                  padding: EdgeInsets.only(left: 4, right: 4),
                  child: Image(image: player.icon)),
              FittedBox(
                fit: BoxFit.fitHeight,
                alignment: Alignment.centerLeft,
                child: Text(
                  player.name,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          FittedBox(
            alignment: Alignment.bottomRight,
            fit: BoxFit.fitHeight,
            child: Text(
              '${player.score}',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }


}