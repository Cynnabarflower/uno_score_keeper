import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_score_keeper/choose_avatar.dart';
import 'package:uno_score_keeper/player.dart';

import 'main.dart';

class AddPlayer extends StatefulWidget {

  @override
  State createState() => _AddPlayerState();

  List<Player> currentPlayers = [];

  AddPlayer(this.currentPlayers) {
    this.currentPlayers ??= [];
  }
}

class _AddPlayerState extends State<AddPlayer> with SingleTickerProviderStateMixin {

  TabController switcherController;
  String playerName = 'Player';
  String avatar = 'assets/images/avatars/001-girl.png';
  var players = [];
  bool playersLoaded = false;


  @override
  void initState() {
    switcherController = TabController(length: 2, vsync: this);
    void loadPlayers() async {
      players = (await SharedPreferences.getInstance()).getStringList('players');
      players.removeWhere((element) => widget.currentPlayers.any((e) => (element as String).split(';')[0] == e.id));
      playersLoaded = true;
      if (players.isNotEmpty) {
        switcherController.index = 1;
      }
      setState((){});
    }
    playerName  = 'Player${widget.currentPlayers.length+1}';
    loadPlayers();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var s = MediaQuery.of(context).size;

    print(s);

    if (s.width < MIN_WIDTH || s.height < MIN_HEIGHT) {
      return smallScreen(context);
    }
    bool kb = s.height - MediaQuery.of(context).viewInsets.bottom < 200 && s.aspectRatio >= 4/3;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          color: Theme.of(context).backgroundColor,
          child: LayoutBuilder(builder: (context, constrains) {
            Function buttonSetState;
            return frame(
              context, constrains,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  s = constraints.biggest;
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
                      Padding(
                        padding: !kb ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
                        child: mySwitcher(
                            ['Create new', 'Choose'],
                                (index){
                                  if (switcherController.indexIsChanging) {
                                    print(index);
                                    setState(() {
                                      if (index == 1 && constrains.maxHeight < 200)
                                        FocusScope.of(context).unfocus();
                                    });
                                  }
                            }),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) =>
                              TabBarView(
                                  controller: switcherController,
                                  children: [
                                    Column (
                                        children: [
                                          Visibility(
                                            visible: !kb,
                                            child: Container(
                                              padding: EdgeInsets.only(top: 16),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => ChooseAvatar(avatar)),
                                                  ).then((value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        avatar = value;
                                                      });
                                                    }
                                                  });
                                                },
                                                child: Image(
                                                  width: 120,
                                                  image: AssetImage(avatar),
                                                ),
                                              ),
                                            ),
                                          ),

                                          TextField(
                                            controller: TextEditingController()..text = playerName,
                                            onChanged: (value) {
                                              playerName = value;
                                              buttonSetState?.call((){});
                                            },
                                            showCursor: true,
                                            autofocus: true,
                                            keyboardType: TextInputType.name,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                                border: new UnderlineInputBorder(
                                                    borderSide: new BorderSide(
                                                        color: Colors.white
                                                    )
                                                )
                                            ),
                                            style: TextStyle(color: Colors.white, fontSize: 50),
                                          )]),
                                    Container(
                                      child: StatefulBuilder(
                                        builder: (context, setState) {

                                          if (playersLoaded) {
                                            if (players.isEmpty) {
                                              return Container(
                                                alignment: Alignment.center,
                                                child: Text('No players here', style: TextStyle(color: Colors.white, fontSize: 40),),
                                              );
                                            }
                                            return Wrap(
                                              children: [
                                                ...(players)
                                                    .map((e) {
                                                  var tokens = e.split(';');
                                                  return getPlayerButton(
                                                      Player(tokens[1], id: tokens[0], assetPath: tokens[2])
                                                  );
                                                })
                                              ],
                                            );
                                          } else {
                                            return SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                strokeWidth: 8,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    )
                                  ]),
                        ),
                      ),

                      Visibility(
                        visible: !kb,
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            buttonSetState = setState;
                            return  Row(
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
                                    onTap: playerName.isNotEmpty ? (){
                                      Player player = Player(playerName, assetPath: avatar);
                                      SharedPreferences.getInstance().then((value) {
                                        String playerImageString = player.assetPath;
                                        String playerString = '${player.id};${player.name};${playerImageString}';
                                        value.setStringList('players', value.getStringList('players')+[playerString]);
                                      });
                                      Navigator.of(context).pop(player);
                                    } : null,
                                    child: Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      margin: new EdgeInsets.only(left: 0.0, top: 8),
                                      decoration: new BoxDecoration(
                                        color: playerName.isNotEmpty ? Theme.of(context).buttonColor : Theme.of(context).buttonColor.withOpacity(0.7),
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
                                            'Add',
                                            style: TextStyle(color: Colors.white.withOpacity(playerName.isEmpty ? 0.7 : 1.0), fontSize: 50),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    ]);},
              ),
            );
          }),
        ),
      ),
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
      onTap: (){Navigator.pop(context, player);},
      child: new Container(
          height: 50.0,
          margin: const EdgeInsets.symmetric(
            vertical: 6.0,
          ),
          child:  Dismissible(
              direction: DismissDirection.endToStart,
              key: Key(player.id),
              onDismissed: (direction) {
                SharedPreferences.getInstance().then((value) {
                  var players = value.getStringList('players');
                  players.removeWhere((element) => element.split(';')[0] == player.id);
                  value.setStringList('players', players);
                });
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

}