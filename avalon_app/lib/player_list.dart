import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/player.dart';
import 'playertile.dart';
import 'services/database.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class playerList extends StatefulWidget {
  DatabaseService game;

  playerList(this.game);

  @override
  _playerListState createState() => _playerListState(game);
}

class _playerListState extends State<playerList> {
  DatabaseService game;

  _playerListState(this.game);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Player> players = Provider.of<List<Player>>(context) ?? [];
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: players.length,
        itemBuilder: (context, index) {
          return playerTile(players: players[index], index: index);
        });
  }
}
