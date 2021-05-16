import 'dart:ui';

import 'package:flutter/cupertino.dart';

class Player {
  String name;
  String assetPath;
  ImageProvider icon;
  String id = '';
  int score = 0;

  Player(this.name, {this.id, this.assetPath, this.icon}) {
    assert(this.assetPath != null || this.icon != null);
    this.icon ??= AssetImage(this.assetPath);
    this.id ??= icon.hashCode.toString()+name;
  }

  @override
  String toString() {
    return 'Player{name: $name, score: $score}';
  }
}