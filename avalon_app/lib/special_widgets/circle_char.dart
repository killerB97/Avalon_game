import 'package:avalonapp/services/database.dart';
import 'package:flutter/material.dart';
import 'package:local_hero/local_hero.dart';
import 'package:sizer/sizer.dart';
import 'package:collection/collection.dart';
import 'package:avalonapp/models/teams.dart';
import 'package:provider/provider.dart';

class circleChar extends StatefulWidget {
  String player_no;
  Map movedLocation;
  Map initialLocation;
  Map questSlotStatus;
  Map userLocation;
  Map CharStatus;
  Map tempLocation;
  DatabaseService game;
  List<String> questTeams;
  List<String> player_list;
  String currLeader;
  List<dynamic> teams;
  List<String> users;
  int teamStrength;
  Function call;

  circleChar(
    this.player_no,
    this.movedLocation,
    this.initialLocation,
    this.questSlotStatus,
    this.CharStatus,
    this.tempLocation,
    this.questTeams,
    this.player_list,
    this.game,
    this.currLeader,
    this.teamStrength,
    this.call,
  );

  @override
  _circleCharState createState() => _circleCharState(
      player_no,
      movedLocation,
      initialLocation,
      questSlotStatus,
      CharStatus,
      tempLocation,
      questTeams,
      player_list,
      game,
      currLeader,
      teamStrength,
      call);
}

class _circleCharState extends State<circleChar> {
  String player_no;
  Map movedLocation;
  Map initialLocation;
  Map questSlotStatus;
  Map CharStatus;
  Map tempLocation;
  DatabaseService game;
  List<String> questTeams;
  List<String> player_list;
  String currLeader;
  String currUser = '1';
  int teamStrength;
  Function call;

  _circleCharState(
    this.player_no,
    this.movedLocation,
    this.initialLocation,
    this.questSlotStatus,
    this.CharStatus,
    this.tempLocation,
    this.questTeams,
    this.player_list,
    this.game,
    this.currLeader,
    this.teamStrength,
    this.call,
  );

  Function eq = const ListEquality().equals;

  @override
  Widget build(BuildContext context) {
    Teams teams = Provider.of<Teams>(context) ?? Teams(teams: []);
    print(player_no);
    return Positioned(
      top: teams.teams.contains(player_list[int.parse(player_no) - 1])
          ? movedLocation['loc' +
              (teams.teams.indexOf(player_list[int.parse(player_no) - 1]) + 1)
                  .toString()][0]
          : initialLocation[player_no][0],
      right: teams.teams.contains(player_list[int.parse(player_no) - 1])
          ? movedLocation['loc' +
              (teams.teams.indexOf(player_list[int.parse(player_no) - 1]) + 1)
                  .toString()][1]
          : initialLocation[player_no][1],
      child: LocalHero(
        tag: 'av' + player_no,
        child: GestureDetector(
          onTap: () {
            if (currUser == currLeader &&
                teams.locked == false &&
                teams.teams.length <= teamStrength) {
              for (int slot = 1; slot <= 5; slot++) {
                if (CharStatus[player_no] != 'None') {
                  if (teams.teams.length == teamStrength) {
                    call('sub');
                  } else {
                    call('sub_lock');
                  }
                  questTeams.remove(player_list[int.parse(player_no) - 1]);
                  game.updateGameQuest(teams: questTeams);
                  setState(() {
                    questSlotStatus[CharStatus[player_no]] = 'empty';

                    CharStatus[player_no] = 'None';
                  });
                  break;
                }
                if (questSlotStatus['loc' + slot.toString()] == 'empty') {
                  if (eq(initialLocation[player_no],
                          movedLocation['loc' + slot.toString()]) ==
                      false) {
                    if (teams.teams.length == teamStrength) {
                      call('add');
                      break;
                    } else {
                      call('add_lock');
                      questTeams.add(player_list[int.parse(player_no) - 1]);
                      game.updateGameQuest(teams: questTeams);
                      setState(() {
                        CharStatus[player_no] = 'loc' + slot.toString();
                        questSlotStatus['loc' + slot.toString()] = 'occupied';
                      });
                      break;
                    }
                  }
                }
              }
            }
          },
          child: CircleAvatar(
            radius: 7.3.w,
            backgroundColor: currLeader != player_no
                ? Colors.grey[100]
                : Color.fromRGBO(255, 220, 128, 1),
            child: CircleAvatar(
              radius: 6.08.w,
              backgroundImage: AssetImage('images/av' + player_no + '.jpeg'),
            ),
          ),
        ),
      ),
    );
  }
}
