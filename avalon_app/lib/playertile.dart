import 'package:avalonapp/models/player.dart';
import 'package:flutter/material.dart';

class playerTile extends StatelessWidget {
  final Player players;
  final int index;
  playerTile({this.players, this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(right: 30, left: 30, bottom: 10),
        child: Card(
          child: ListTile(
            title: Text((index + 1).toString() + '.  ' + players.username,
                style: TextStyle(fontFamily: 'hash', fontSize: 30)),
            trailing: CircleAvatar(
              backgroundImage:
                  AssetImage('images/av' + (index + 1).toString() + '.jpeg'),
            ),
          ),
        ),
      ),
    );
  }
}
