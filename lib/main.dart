import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_score_keeper/add_player.dart';
import 'package:uno_score_keeper/game_setup.dart';
import 'package:url_launcher/url_launcher.dart';

import 'game.dart';

var lang = 'ru';
enum GAMES { BALLOONS, ROBOT, CLOWN}

const MIN_WIDTH = 100;
const MIN_HEIGHT = 200;


void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  
  static MaterialColor myGreen = MaterialColor(0xFF3CA544, {
    50 : Color(0xFF3CA544),
    100 : Color(0xFF3CA544),
    200 : Color(0xFF3CA544),
    300 : Color(0xFF3CA544),
    400 : Color(0xFF3CA544),
    500 : Color(0xFF3CA544),
    600 : Color(0xFF3CA544),
    700 : Color(0xFF3CA544),
    800 : Color(0xFF3CA544),
    900 : Color(0xFF3CA544),
  });
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        accentColor: Colors.red,
        buttonColor: Colors.blueAccent,
        backgroundColor: kIsWeb ? myGreen : myGreen,
      ),
      home: Menu(),
    );
  }

}

class Menu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MenuState();
}



Widget smallScreen(context) {
  return Scaffold(
    body: SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        color: Theme.of(context).backgroundColor,
        child: LayoutBuilder(builder: (context, constrains) {
          return Card(
            elevation: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Container(
                    color: Colors.white,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            'Please expand the window\n'
                                'Пожалуйста разверните окно на весь экран',
                            style: TextStyle(
                                color: Colors.lightBlue,
                                fontSize: 50,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                      ),
                    ])),
              ),
            ),
          );
        }),
      ),
    ),
  );
}


Widget frame(context, constrains, {fixed : true, Widget child}) {

  if (!kIsWeb)
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: child,
    );

  double aspectRatio = constrains.biggest.aspectRatio;
  double paddingKoeff = 1.0;
  if (fixed && aspectRatio > 9 / 16) {
    if (constrains.biggest.width < 600 && constrains.biggest.height < 600) {
      paddingKoeff = (600 - constrains.biggest.longestSide) / 600;
    }
    else if (constrains.biggest.width < 600) {
      paddingKoeff = (constrains.biggest.width) / 600;
      aspectRatio = ((600 - constrains.biggest.width) / 600 + 1) * 9 / 16;
    } else if (constrains.biggest.height < 600) {
      paddingKoeff = (constrains.biggest.height) / 600;
      aspectRatio = 9 / 16 +
          (600 - constrains.biggest.height) / 600 * (aspectRatio - 9 / 16);
    } else {
      aspectRatio = 9 / 16;
    }
  }



  return Center(
    child: Padding(
        padding: EdgeInsets.all(16.0 * paddingKoeff),
        child: LimitedBox(
            maxWidth: constrains.maxWidth / 5,
            child: AspectRatio(
                aspectRatio: aspectRatio,
                child: Hero(
                    tag: 'menuCard',
                    child: Card(
                      color: MyApp.myGreen,
                        elevation: 0,
                        // color: Colors.white,
                        // shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.all(Radius.circular(
                        //         constrains.biggest.shortestSide / 40))
                        // ),
                        child: Padding(
                            padding:
                            EdgeInsets.all(
                                constrains.biggest.shortestSide / 80 * 0),
                            child: Container(
                                // padding: EdgeInsets.all(
                                //     constrains.biggest.shortestSide / 80 * 0),
                                decoration: BoxDecoration(
                                    color: MyApp.myGreen,
                                    // borderRadius: BorderRadius.all(
                                    //     Radius.circular(
                                    //         constrains.biggest.shortestSide /
                                    //             40))
                                ),
                                child: child)
                        )
                    )
                )
            )
        )
    ),
  );
}

class _MenuState extends State<Menu> {

  bool hasSavedGame = false;


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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return frame(context, constraints,
            child: LayoutBuilder(
              builder: (context, constraints) {
                s = constraints.biggest;
                return
              Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          padding: EdgeInsets.only(right: 8),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Image(
                              image: AssetImage('assets/images/uno_image.png'),
                            ),
                          ),
                        ),
                        Text(
                          'Uno Score Keeper',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: s.aspectRatio < 5/3 ? 50 : 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: getGameButton(
                              lang == 'ru' ? 'Новая игра' : 'New game',
                              'uno.png', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GameSetup()),
                            ).then((value) => checkSaved());
                          }, Colors.white.withOpacity(0.1), ratio: min(s.height/500, 1.0)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: getGameButton(
                              lang == 'ru' ? 'Загрузить' : 'Load',
                              'balloons-pattern.jpg', hasSavedGame ? () async {
                            var game = await Game.load();
                            if (game != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    game),
                              );
                            } else {
                              print('No no no');
                            }
                          } : null, Colors.yellowAccent.withOpacity(0.1),
                              ratio: min(s.height/500, 1.0)
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: getGameButton(
                              lang == 'ru' ? 'Мои игроки' : 'My players',
                              'clown-pattern.jpg', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddPlayer([])),
                            );
                          }, Colors.white.withOpacity(0.1),
                              ratio: min(s.height/500, 1.0)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: getGameButton(
                              lang == 'ru' ? 'Правила' : 'Rules',
                              'question_pattern2.jpg', () async {
                            if (kIsWeb) {
                              launch('https://firebasestorage.googleapis.com/v0/b/uno-score-keeper-5d173.appspot.com/o/uno.pdf?alt=media&token=f53e2a5f-e2ab-45b3-ab54-cf03130b8b49');
                            } else {
                              try {
                                Future<File> copyAsset() async {
                                  Directory tempDir = await getTemporaryDirectory();
                                  String tempPath = tempDir.path;
                                  File tempFile = File('$tempPath/rules.pdf');
                                  ByteData bd = await rootBundle.load(
                                      'assets/data/rules.pdf');
                                  await tempFile.writeAsBytes(
                                      bd.buffer.asUint8List(), flush: true);
                                  return tempFile;
                                }
                                File f = await copyAsset();
                                OpenFile.open(f.path);
                              } catch (e) {
                                launch('https://firebasestorage.googleapis.com/v0/b/uno-score-keeper-5d173.appspot.com/o/uno.pdf?alt=media&token=f53e2a5f-e2ab-45b3-ab54-cf03130b8b49');
                              }
                            }
                          }, Colors.white.withOpacity(0.1),
                              ratio: min(s.height/500, 1.0)),
                        ),
                      ]
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) =>
                          //           RegistrationForm()),
                          // );
                        },
                        child: ClipRect(
                          child: Container(
                            height: 40,
                            margin: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: AnimatedSwitcher(
                              duration:
                              Duration(milliseconds: 500),
                              child: max(
                                  constraints.maxWidth /
                                      5,
                                  constraints.maxHeight *
                                      9 /
                                      16) >
                                  310
                                  ? Row(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .center,
                                children: [
                                  Padding(
                                      padding: EdgeInsets
                                          .symmetric(
                                          horizontal:
                                          4),
                                      child: Icon(
                                        Icons
                                            .account_circle,
                                        color:
                                        Colors.white,
                                      )),
                                  Text(
                                    lang == 'ru'
                                        ? 'Войти '
                                        : 'Log in',
                                    style: TextStyle(
                                        color:
                                        Colors.white),
                                  )
                                ],
                              )
                                  : Padding(
                                  padding:
                                  EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Icon(
                                    Icons.account_circle,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                      ),
                      languageRaw()
                    ],
                  ),
                )
              ]);},
            )
            );
          }
        ),
      ),
    );
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      if (value.getStringList("players") == null) {
        value.setStringList('players', []);
        checkSaved();
      }
    });
    super.initState();
  }

  void checkSaved() async {
    SharedPreferences.getInstance().then((value) {
      hasSavedGame = value.containsKey("game");
      if (hasSavedGame) {
        setState(() {});
      }
    });
  }

  Widget getGameButton(text, image, pressed, color,
      {textColor = Colors.white, ratio = 1.0} ) {
    var blur = 0.5;

    var planetThumbnail = new Container(
      alignment: FractionalOffset.centerLeft,
      child: ClipOval(
        child: new Image(
          image: AssetImage('assets/images/'+image),
          height: 48.0 * ratio,
          width: 48.0 * ratio,
        ),
      ),
    );

    final planetCard = new Container(
      alignment: Alignment.center,
     // margin: new EdgeInsets.only(left: 24.0* ratio),
      decoration: new BoxDecoration(
        color: Theme.of(context).buttonColor.withOpacity(pressed == null ? 0.6 : 1.0),
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0 * ratio),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0 * ratio,
            offset: new Offset(0.0, 6.0 * ratio),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(8 * ratio),
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 50 * sqrt(ratio)),
          ),
        ),
      ),
    );

    return InkWell(
      onTap: pressed,
      child: new Container(
          height: 70.0 * ratio,
          margin: EdgeInsets.symmetric(
            vertical: 12.0 * ratio,
          ),
          child: new Stack(
            children: <Widget>[
              planetCard,
              //planetThumbnail,
            ],
          )),
    );
  }

  Widget languageRaw() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                lang = 'ru';
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color:
                        lang == 'ru' ? Colors.black26 : Colors.transparent,
                        blurRadius: 10.0,
                        offset: Offset(0, 0.0))
                  ]),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: lang == 'ru' ? 1 : 0.4,
                child: Image(
                  image: AssetImage('assets/images/ru_flag.png'),
                  width: 48,
                  height: 48,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                lang = 'en';
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(48)),
                  boxShadow: [
                    BoxShadow(
                        color:
                        lang == 'en' ? Colors.black26 : Colors.transparent,
                        blurRadius: 10.0,
                        offset: Offset(0, 0.0))
                  ]),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: lang == 'en' ? 1 : 0.4,
                child: Image(
                  image: AssetImage('assets/images/uk_flag.png'),
                  width: 48,
                  height: 48,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}