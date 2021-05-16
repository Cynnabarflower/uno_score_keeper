import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class ChooseAvatar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChooseAvatarState();

  String currentAvatar;
  ChooseAvatar(this.currentAvatar);
}

class _ChooseAvatarState extends State<ChooseAvatar> {

  List<AssetImage> avatars = [];

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
        child: Container(
          alignment: Alignment.center,
          color: Theme.of(context).backgroundColor,
          child: LayoutBuilder(builder: (context, constrains) {
            return frame(
              context, constrains,
               fixed: false,
               child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Stack(
                            children: [
                              Text(
                                'Uno Score Keeper',
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
                      Expanded(
                        child: LayoutBuilder(
                            builder: (context, constrains) {
                              var iconSize = min(min(constrains.maxHeight/4, constrains.maxWidth / 4), 70.0);
                              if (avatars.isEmpty) {
                                return Center(
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 6,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                );
                              }

                              return SingleChildScrollView(
                                child: Wrap(
                                  children: [
                                    ...avatars.map((e) => GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop(e.assetName);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image(
                                              width: iconSize,
                                              height: iconSize,
                                              image: e),
                                        )))
                                  ],
                                ),
                              );
                            }
                        ),
                      )

                    ])
            );
          }),
        ),
      ),
    );
  }

  @override
  void initState() {
    DefaultAssetBundle.of(context).loadString('AssetManifest.json').then((value) {
      avatars = (json.decode(value).keys.where((String key) => key.startsWith('assets/images/avatars'))
          .toList() as List)
          .map((e) => AssetImage(e))
          .toList();
      setState(() {});
    });

  }
}