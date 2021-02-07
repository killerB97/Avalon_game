import 'package:avalonapp/models/player.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class playerTile extends StatelessWidget {
  final Player players;
  final int index;
  playerTile({this.players, this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: Padding(
        padding: EdgeInsets.only(right: 6.0.w, left: 6.0.w, bottom: 2),
        child: Card(
          child: Center(
            child: ListTile(
              title: Text((index + 1).toString() + '.  ' + players.username,
                  style: TextStyle(fontFamily: 'hash', fontSize: 25)),
              trailing: CircleAvatar(
                backgroundImage:
                    AssetImage('images/av' + (index + 1).toString() + '.jpeg'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
