import 'dart:ffi';

import 'package:avalonapp/models/teams.dart';
import 'package:flutter/services.dart';
import 'package:avalonapp/screens/winner.dart';
import 'package:avalonapp/services/database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:avalonapp/models/groups.dart';
import 'package:avalonapp/models/policy.dart';
import 'package:smart_flare/smart_flare.dart';
import 'package:flutter/scheduler.dart';
import 'package:avalonapp/network/disconnected.dart';
import 'package:connectivity/connectivity.dart';
import 'package:collection/collection.dart';
import 'package:local_hero/local_hero.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:shape_of_view/shape_of_view.dart';
import 'package:avalonapp/circleReveal.dart';
import 'dart:async';
import 'dart:math';

class roundTable extends StatefulWidget {
  List<String> player_list;
  String head;
  List<String> users;
  String currUser;
  DatabaseService game;
  String role;
  List<String> roleList;
  roundTable(this.player_list, this.head, this.users, this.currUser, this.game,
      this.role, this.roleList);
  @override
  _roundTableState createState() => _roundTableState(
      player_list, head, users, currUser, game, role, roleList);
}

class _roundTableState extends State<roundTable> {
  List<String> player_list;
  String head;
  String flag;
  String prevAnimation = 'activate';
  Function eq = const ListEquality().equals;
  _roundTableState(this.player_list, this.head, this.users, this.currUser,
      this.game, this.role, this.roleList);
  String rounds = 'Round1';
  List<String> questTeams = [];
  int leaderIndex = 0;
  DatabaseService game;
  bool selected = false;
  String currUser;
  int votePass = 1;
  int roundPass = 1;
  bool reset = false;
  bool resetPolicy = false;
  bool resetLoad = false;
  bool resetResults = false;
  String horse;
  int evilScore = 0;
  int goodScore = 0;
  bool policyTrans = false;
  bool stopPolicyState = false;
  bool endGame = false;
  bool merlinVote = false;
  bool lockGame = false;
  bool networkDialog = false;
  bool networkRouteCheck = false;
  bool networkRelated;
  ValueNotifier<bool> error = ValueNotifier<bool>(false);
  int errorMessage = 0;
  String currentLeader;
  String role;
  int merlinChoice = -1;
  List<String> users;
  List<String> deck = [];
  List<String> roleList;
  ConnectivityResult modeChange;

  Map charTeams = {
    'Percival': 0,
    'Mordred': 1,
    'Merlin': 0,
    'Morgana': 1,
    'Loyal Knight': 0,
    'Oberon': 1,
    'Minion': 1
  };

  Map sides = {'good': 0, 'evil': 1};

  Map initialLocation = {
    '1': [88.0.w * 0.2 + 18.0.h, 88.0.w * 0.05 + 6.08.w],
    '2': [88.0.w * 0.62 + 18.0.h, 88.0.w * 0.05 + 6.08.w],
    '3': [88.0.w * 0.82 + 18.0.h, 88.0.w * 0.4 + 6.08.w],
    '4': [88.0.w * 0.62 + 18.0.h, 88.0.w * 0.785 + 6.08.w],
    '5': [88.0.w * 0.18 + 18.0.h, 88.0.w * 0.785 + 6.08.w],
    '6': [88.0.w * 0.03 + 18.0.h, 88.0.w * 0.42 + 6.08.w],
    '7': [88.0.w * 0.41 + 18.0.h, 88.0.w * 0.82 + 6.08.w],
    '8': [88.0.w * 0.41 + 18.0.h, 88.0.w * 0.02 + 6.08.w],
    '9': [88.0.w * 0.785 + 18.0.h, 88.0.w * 0.18 + 6.08.w],
    '10': [88.0.w * 0.785 + 18.0.h, 88.0.w * 0.62 + 6.08.w]
  };

  Map userLocation = {
    '1': [88.0.w * 0.18 + 18.0.h, 88.0.w * 0.05 + 6.08.w],
    '2': [88.0.w * 0.6 + 18.0.h, 88.0.w * 0.05 + 6.08.w],
    '3': [88.0.w * 0.8 + 18.0.h, 88.0.w * 0.4 + 6.08.w],
    '4': [88.0.w * 0.6 + 18.0.h, 88.0.w * 0.785 + 6.08.w],
    '5': [88.0.w * 0.16 + 18.0.h, 88.0.w * 0.785 + 6.08.w],
    '6': [88.0.w * 0.01 + 18.0.h, 88.0.w * 0.42 + 6.08.w],
    '7': [88.0.w * 0.385 + 18.0.h, 88.0.w * 0.82 + 6.08.w],
    '8': [88.0.w * 0.385 + 18.0.h, 88.0.w * 0.02 + 6.08.w],
    '9': [88.0.w * 0.785 + 18.0.h, 88.0.w * 0.18 + 6.08.w],
    '10': [88.0.w * 0.785 + 18.0.h, 88.0.w * 0.62 + 6.08.w]
  };

  Map tempLocation = {
    '1': [88.0.w * 0.2 + 18.0.h, 88.0.w * 0.05 + 6.08.w],
    '2': [88.0.w * 0.62 + 18.0.h, 88.0.w * 0.05 + 6.08.w],
    '3': [88.0.w * 0.82 + 18.0.h, 88.0.w * 0.4 + 6.08.w],
    '4': [88.0.w * 0.62 + 18.0.h, 88.0.w * 0.785 + 6.08.w],
    '5': [88.0.w * 0.18 + 18.0.h, 88.0.w * 0.785 + 6.08.w],
    '6': [88.0.w * 0.03 + 18.0.h, 88.0.w * 0.42 + 6.08.w],
    '7': [88.0.w * 0.42 + 18.0.h, 88.0.w * 0.82 + 6.08.w],
    '8': [88.0.w * 0.42 + 18.0.h, 88.0.w * 0.02 + 6.08.w],
    '9': [88.0.w * 0.785 + 18.0.h, 88.0.w * 0.18 + 6.08.w],
    '10': [88.0.w * 0.785 + 18.0.h, 88.0.w * 0.62 + 6.08.w]
  };

  Map movedLocation = {
    'loc1': [14.5.h * 0.4, 88.0.w * 0.8 + 6.08.w],
    'loc2': [14.5.h * 0.4, 88.0.w * 0.6 + 6.08.w],
    'loc3': [14.5.h * 0.4, 88.0.w * 0.4 + 6.08.w],
    'loc4': [14.5.h * 0.4, 88.0.w * 0.2 + 6.08.w],
    'loc5': [14.5.h * 0.4, 88.0.w * 0.0 + 6.08.w]
  };

  Map questSlotStatus = {
    'loc1': 'empty',
    'loc2': 'empty',
    'loc3': 'empty',
    'loc4': 'empty',
    'loc5': 'empty'
  };

  Map CharStatus = {
    '1': 'None',
    '2': 'None',
    '3': 'None',
    '4': 'None',
    '5': 'None',
    '6': 'None',
    '7': 'None',
    '8': 'None',
    '9': 'None',
    '10': 'None'
  };

  Map roundStatus = {1: null, 2: null, 3: null, 4: null, 5: null};

  Map roundTrack = {
    2: [2, 1, 1, 1, 1],
    5: [2, 3, 2, 3, 3],
    6: [2, 3, 4, 3, 4],
    7: [2, 3, 3, 4, 4],
    8: [3, 4, 4, 5, 5],
    9: [3, 4, 4, 5, 5],
    10: [3, 4, 4, 5, 5]
  };

  @override
  void initState() {
    game.connectToGame();
    game.updateGameQuest();
    game.voteTracker(rounds: 'Round1');
    game.updateGamePolicy();
    currentLeader = player_list[0];
    super.initState();
  }

  void resetStatus() {
    CharStatus = {
      '1': 'None',
      '2': 'None',
      '3': 'None',
      '4': 'None',
      '5': 'None',
      '6': 'None',
      '7': 'None',
      '8': 'None',
      '9': 'None',
      '10': 'None'
    };

    questSlotStatus = {
      'loc1': 'empty',
      'loc2': 'empty',
      'loc3': 'empty',
      'loc4': 'empty',
      'loc5': 'empty'
    };

    questTeams = [];
  }

  double nameSpace(int userLength) {
    if (userLength == 1) {
      return -0.2;
    } else if (userLength == 2) {
      return 0.1;
    } else if (userLength == 3) {
      return 0.25;
    } else {
      return 0.33;
    }
  }

  void callback(String rule) {
    if (rule == 'add' && error.value == false) {
      error.value = !error.value;
      errorMessage = 0;
    }
    if (rule == 'add_lock' && errorMessage == 1) {
      error.value = !error.value;
      errorMessage = 0;
    }
    if (rule == 'sub_lock' && errorMessage == 1) {
      error.value = !error.value;
      errorMessage = 0;
    }
    if (rule == 'sub' && error.value == true) {
      error.value = !error.value;
      errorMessage = 0;
    }
    if (rule == 'lock' && error.value == false) {
      error.value = !error.value;
      errorMessage = 1;
    }
  }

  List<Widget> showPolicy(int pass, int fail, bool firstRow) {
    List<Widget> cards = [];
    if (firstRow) {
      if (deck.length < pass + fail) {
        for (int i = 0; i < pass; i++) {
          deck.add('PASS');
        }
        for (int i = 0; i < fail; i++) {
          deck.add('FAIL');
        }
      }
      int delay = 1;
      deck.shuffle();
      for (String i in deck) {
        if (delay > 3) {
          return cards;
        }
        cards.add(SizedBox(
          width: delay == 1
              ? 125 -
                  (min(deck.length, 3) *
                              (90 - (min(deck.length, 3) * 10).toDouble()) +
                          ((min(deck.length, 3) - 1) * 20)) /
                      2
              : 20,
        ));
        cards.add(DelayedDisplay(
          delay: Duration(seconds: delay),
          child: Container(
            height: 130 - (min(deck.length, 3) * 10).toDouble(),
            width: 90 - (min(deck.length, 3) * 10).toDouble(),
            child: FadeInImage(
              placeholder: AssetImage('images/transparent.png'),
              // here `bytes` is a Uint8List containing the bytes for the in-memory image
              image: AssetImage('images/' + i + '.png'),
            ),
          ),
        ));
        delay += 1;
      }
    } else {
      int delay = 4;
      for (String i in deck.sublist(3)) {
        cards.add(SizedBox(
          width: delay == 4
              ? 125 - ((deck.length - 3) * 60 + ((deck.length - 4) * 20)) / 2
              : 20,
        ));
        cards.add(DelayedDisplay(
          delay: Duration(seconds: delay),
          child: Container(
            height: 100,
            width: 60,
            child: FadeInImage(
              placeholder: AssetImage('images/transparent.png'),
              // here `bytes` is a Uint8List containing the bytes for the in-memory image
              image: AssetImage('images/' + i + '.png'),
            ),
          ),
        ));
        delay += 1;
      }
      deck = [];
    }
    return cards;
  }

  createPolicyDialog(BuildContext context, Teams team) {
    Size size = MediaQuery.of(context).size;
    horse = 'load';
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Center(
                  child: Text(
                "Quest Result",
                style: TextStyle(
                    color: Colors.grey[800],
                    fontFamily: 'bondi',
                    fontSize: 22,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none),
              )),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter policy) {
                return StreamProvider.value(
                    initialData: Policy(passCount: 0, failCount: 0),
                    value: game.policy,
                    child:
                        Consumer<Policy>(builder: (context, Policy pol, child) {
                      if (pol.passCount + pol.failCount == team.teams.length &&
                          stopPolicyState == false) {
                        horse = 'success';
                        stopPolicyState = true;
                        Timer(Duration(milliseconds: 2000), () {
                          policy(() {
                            policyTrans = true;
                          });
                        });
                        Timer(
                            Duration(
                                milliseconds: max(7500,
                                    2500 * (pol.passCount + pol.failCount))),
                            () {
                          if (resetResults == false) {
                            roundPass += 1;
                            votePass = 1;
                            leaderIndex =
                                (leaderIndex + 1) % player_list.length;
                            rounds = 'Round' + roundPass.toString();
                            reset = false;
                            resetPolicy = false;
                            resetLoad = false;
                            stopPolicyState = false;
                            resetResults = true;
                            policyTrans = false;
                            deck = [];
                            resetStatus();
                            if (currUser == currentLeader) {
                              networkRelated = false;
                              game.updateGameQuest();
                              game.updateVoteTracker(
                                  rounds: 'Round' + roundPass.toString());
                              game.updateGamePolicy();
                              currentLeader = player_list[leaderIndex];
                            } else {
                              setState(() {
                                currentLeader = player_list[leaderIndex];
                              });
                            }
                            Navigator.of(context).pop();
                            setState(() {
                              roundStatus[roundPass - 1] = users.length < 7
                                  ? pol.failCount >= 1
                                      ? 'fail'
                                      : 'pass'
                                  : pol.failCount >= 2
                                      ? 'fail'
                                      : 'pass';
                              if (roundStatus[roundPass - 1] == 'fail') {
                                evilScore += 1;
                              } else {
                                goodScore += 1;
                              }
                            });
                          }
                        });
                      }
                      return policyTrans == false
                          ? Container(
                              child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Awaiting Quest Decisions...',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'hash',
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none),
                                  ),
                                  SizedBox(height: 20),
                                  Flexible(
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      child: FlareActor('images/horse.flr',
                                          animation: horse),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                          : Container(
                              height: 250,
                              width: 250,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 20),
                                  Row(
                                    children: showPolicy(
                                        pol.passCount, pol.failCount, true),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  team.teams.length > 3
                                      ? Row(
                                          children: showPolicy(pol.passCount,
                                              pol.failCount, false))
                                      : Container()
                                ],
                              ),
                            );
                    }));
              }));
        });
  }

  Widget circleChar(String player_no, int teamStrength, Teams teams) {
    return Positioned(
      top: player_list[int.parse(player_no) - 1] == currentLeader
          ? teams.teams.contains(player_list[int.parse(player_no) - 1])
              ? movedLocation['loc' +
                      (teams.teams.indexOf(
                                  player_list[int.parse(player_no) - 1]) +
                              1)
                          .toString()][0] -
                  14
              : initialLocation[player_no][0] - 14
          : teams.teams.contains(player_list[int.parse(player_no) - 1])
              ? movedLocation['loc' +
                  (teams.teams.indexOf(player_list[int.parse(player_no) - 1]) +
                          1)
                      .toString()][0]
              : initialLocation[player_no][0],
      right: player_list[int.parse(player_no) - 1] == currentLeader
          ? teams.teams.contains(player_list[int.parse(player_no) - 1])
              ? movedLocation['loc' +
                      (teams.teams.indexOf(
                                  player_list[int.parse(player_no) - 1]) +
                              1)
                          .toString()][1] -
                  12
              : initialLocation[player_no][1] - 12
          : teams.teams.contains(player_list[int.parse(player_no) - 1])
              ? movedLocation['loc' +
                  (teams.teams.indexOf(player_list[int.parse(player_no) - 1]) +
                          1)
                      .toString()][1]
              : initialLocation[player_no][1],
      child: LocalHero(
        tag: 'av' + roundPass.toString() + votePass.toString() + player_no,
        key: ValueKey(roundPass + votePass),
        child: GestureDetector(
          onTap: () {
            if (currUser == currentLeader &&
                teams.locked == false &&
                teams.teams.length <= teamStrength &&
                lockGame == false) {
              for (int slot = 1; slot <= 5; slot++) {
                if (CharStatus[player_no] != 'None') {
                  if (teams.teams.length == teamStrength) {
                    callback('sub');
                  } else {
                    callback('sub_lock');
                  }
                  questTeams.remove(player_list[int.parse(player_no) - 1]);
                  networkRelated = false;
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
                      callback('add');
                      break;
                    } else {
                      callback('add_lock');
                      questTeams.add(player_list[int.parse(player_no) - 1]);
                      networkRelated = false;
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
          child: currentLeader == player_list[int.parse(player_no) - 1]
              ? Stack(children: [
                  Container(
                    height: 2.83 * 7.3.w,
                    width: 2.83 * 7.3.w,
                    child: FlareActor('images/glow.flr', animation: 'Glow'),
                  ),
                  Positioned(
                    top: 0.72 * 6.08.w,
                    left: 0.68 * 6.08.w,
                    child: CircleAvatar(
                      radius: 6.08.w,
                      backgroundImage:
                          AssetImage('images/av' + player_no + '.jpeg'),
                    ),
                  ),
                ])
              : CircleAvatar(
                  radius: 7.3.w,
                  backgroundColor:
                      currentLeader != player_list[int.parse(player_no) - 1]
                          ? Colors.grey[300]
                          : Color.fromRGBO(255, 220, 128, 1),
                  child: CircleAvatar(
                    radius: 6.08.w,
                    backgroundImage:
                        AssetImage('images/av' + player_no + '.jpeg'),
                  ),
                ),
        ),
      ),
    );
  }

  Widget gameCounts(String numb, int sel, String track, bool multiFail) {
    return track == 'quest'
        ? roundStatus[sel] != null
            ? Container(
                height: 4.50.h,
                width: 4.50.h,
                child: Stack(overflow: Overflow.visible, children: [
                  Positioned(
                    top: 0.16 * 4.0.h,
                    child: Container(
                      height: 4.0.h,
                      width: 4.0.h,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                    ),
                  ),
                  Positioned(
                    top: 0.21 * 4.3.h,
                    left: -0.0325 * 4.3.h,
                    child: Container(
                        height: 4.3.h,
                        width: 4.3.h,
                        child: FlareActor('images/Victory.flr',
                            animation: roundStatus[sel] == 'pass'
                                ? 'virtVic'
                                : 'evilVic')),
                  ),
                ]),
              )
            : Padding(
                padding: EdgeInsets.only(top: 0.9.h),
                child: Container(
                  height: 4.0.h,
                  width: 4.0.h,
                  decoration: BoxDecoration(
                      color: track == 'vote'
                          ? (votePass == sel
                              ? //Colors.white
                              Color(0xffffc68a)
                              : Color(0xff1e1e1e)) //Color(0xffffe7a6))
                          : (roundPass == sel
                              ? Color(0xffffc68a) //Colors.white
                              : Color(0xff1e1e1e)),
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: Center(
                    child: multiFail
                        ? Column(
                            children: [
                              Text(numb,
                                  style: TextStyle(
                                      fontFamily: 'hash',
                                      fontSize: 11.0.sp,
                                      color:
                                          (votePass == sel || roundPass == sel)
                                              ? Color(0xff111111)
                                              : Color(0xffffc68a),
                                      decoration: TextDecoration.none)),
                              Text('2 fail',
                                  style: TextStyle(
                                      fontFamily: 'hash',
                                      fontSize: 6.5.sp,
                                      color: (roundPass == sel)
                                          ? Color(0xff111111)
                                          : Color(0xffffc68a),
                                      decoration: TextDecoration.none)),
                            ],
                          )
                        : Text(numb,
                            style: TextStyle(
                                fontFamily: 'hash',
                                fontSize: 12.0.sp,
                                color: (roundPass == sel)
                                    ? Color(0xff111111)
                                    : Color(0xffffc68a),
                                decoration: TextDecoration.none)),
                  ),
                ),
              )
        : Padding(
            padding: EdgeInsets.only(top: 0.9.h),
            child: Container(
              height: 4.0.h,
              width: 4.0.h,
              decoration: BoxDecoration(
                  color: track == 'vote'
                      ? (votePass == sel
                          ? Color(0xffffc68a) //Colors.white
                          : Color(0xff1e1e1e)) //Color(0xffffe7a6))
                      : (roundPass == sel
                          ? Color(0xffffc68a) //Colors.white
                          : Color(0xff1e1e1e)), //Color(0xffffe7a6)),
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Center(
                child: Text(numb,
                    style: TextStyle(
                        fontFamily: 'hash',
                        fontSize: 12.0.sp,
                        color: (votePass == sel)
                            ? Color(0xff111111)
                            : Color(0xffffc68a),
                        decoration: TextDecoration.none)),
              ),
            ),
          );
  }

  List<Widget> getVoteTallyUsers(Groups group) {
    List<Widget> Users = [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          alignment: Alignment.topCenter,
          height: 8,
          width: 50,
          decoration: BoxDecoration(
            color: Color(0xffffc68a), //Colors.grey[400],
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Aye',
            style: TextStyle(
                color: Color(0xff16c79a),
                fontFamily: 'hash',
                fontSize: 40,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none),
          ),
          SizedBox(
            width: 24.3.w,
          ),
          Text(
            'Nay',
            style: TextStyle(
                color: Color(0xffef4f4f),
                fontFamily: 'hash',
                fontSize: 40,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none),
          ),
        ],
      ),
      SizedBox(
        height: 5,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            group.ayeCount.toInt().toString(),
            style: TextStyle(
                color: Color(0xffffc180), //Colors.grey[800],
                fontFamily: 'hash',
                fontSize: 15,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none),
          ),
          SizedBox(
            width: 36.5.w,
          ),
          Text(
            group.nayCount.toInt().toString(),
            style: TextStyle(
                color: Color(0xffffc180), //Colors.grey[800],
                fontFamily: 'hash',
                fontSize: 15,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none),
          )
        ],
      ),
    ];
    int balance = min(group.ayeGroup.length, group.nayGroup.length);
    for (int i = 0; i < balance; i++) {
      Users.add(SizedBox(
        height: 10,
      ));
      Users.add(
        Row(
          children: [
            SizedBox(
              width: (32.0.w -
                      users[player_list.indexOf(group.ayeGroup[i])].length * 5)
                  .toDouble(),
            ),
            Text(
              users[player_list.indexOf(group.ayeGroup[i])],
              style: TextStyle(
                  color: Color(0xffffc68a), //Colors.black,
                  fontFamily: 'hash',
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none),
            ),
            SizedBox(
                width: (24.3.w +
                        (45.0.w -
                                users[player_list.indexOf(group.nayGroup[i])]
                                        .length *
                                    5)
                            .toDouble()) -
                    ((30.4.w -
                                users[player_list.indexOf(group.ayeGroup[i])]
                                        .length *
                                    5)
                            .toDouble() +
                        10 *
                            users[player_list.indexOf(group.ayeGroup[i])]
                                .length)),
            Text(
              users[player_list.indexOf(group.nayGroup[i])],
              style: TextStyle(
                  color: Color(0xffffc68a), //Colors.black,
                  fontFamily: 'hash',
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none),
            )
          ],
        ),
      );
    }
    if (group.ayeGroup.length > group.nayGroup.length) {
      for (int j = balance; j < group.ayeGroup.length; j++) {
        Users.add(SizedBox(
          height: 10,
        ));
        Users.add(
          Row(
            children: [
              SizedBox(
                width: (32.0.w -
                        users[player_list.indexOf(group.ayeGroup[j])].length *
                            5)
                    .toDouble(),
              ),
              Text(
                users[player_list.indexOf(group.ayeGroup[j])],
                style: TextStyle(
                    color: Color(0xffffc68a), //Colors.black,
                    fontFamily: 'hash',
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none),
              ),
            ],
          ),
        );
      }
    } else if (group.ayeGroup.length < group.nayGroup.length) {
      for (int j = balance; j < group.nayGroup.length; j++) {
        Users.add(SizedBox(
          height: 10,
        ));
        Users.add(
          Row(
            children: [
              SizedBox(
                width: 24.3.w,
              ),
              SizedBox(
                width: (45.0.w -
                        users[player_list.indexOf(group.nayGroup[j])].length *
                            5)
                    .toDouble(),
              ),
              Text(
                users[player_list.indexOf(group.nayGroup[j])],
                style: TextStyle(
                    color: Color(0xffffc68a), //Colors.black,
                    fontFamily: 'hash',
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none),
              )
            ],
          ),
        );
      }
    }
    return Users;
  }

  List<Widget> getPlayerAvatars(Teams team) {
    List<Widget> playerAvatar = [
      Positioned(
        top: 1.16.h,
        left: 0,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.16.h, horizontal: 12.16.w),
          child: Text(
            'Quest Team:',
            style: TextStyle(
                fontFamily: 'hash',
                fontSize: 10.0.sp,
                color: Color(0xffffc68a), //Colors.black,
                decoration: TextDecoration.none),
          ),
        ),
      ),
      ValueListenableBuilder<bool>(
          valueListenable: error,
          builder: (context, value, child) {
            return error.value == true
                ? Positioned(
                    top: 1.22.h,
                    left: 80,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 1.16.h, horizontal: 12.16.w),
                      child: Text(
                        errorMessage == 0
                            ? 'Only ' +
                                roundTrack[player_list.length][roundPass - 1]
                                    .toString() +
                                ' player teams for this round'
                            : 'you have not selected ' +
                                roundTrack[player_list.length][roundPass - 1]
                                    .toString() +
                                ' players',
                        style: TextStyle(
                            fontFamily: 'hash',
                            fontSize: 9.5.sp,
                            color: Colors.redAccent,
                            decoration: TextDecoration.none),
                      ),
                    ),
                  )
                : Container();
          }),
      Positioned(
        top: 1.16.h,
        right: 10.0.w,
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter iconState) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () async {
                if (lockGame == true) {
                } else if (team.teams.length !=
                    roundTrack[player_list.length][roundPass - 1]) {
                  callback('lock');
                } else {
                  iconState(() {
                    selected = !selected;
                  });
                  networkRelated = false;
                  game.updateGameQuestLock(lock: selected);
                  //game.updateVoteTracker(rounds: rounds);
                }
              },
              child: currUser == currentLeader
                  ? Container(
                      height: 3.66.h,
                      width: 3.66.h,
                      decoration: BoxDecoration(
                        color: Color(0xff111111), //Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey[300],
                              blurRadius: 0,
                              spreadRadius: 0.0,
                              offset: Offset(0.0, 0.0)),
                        ],
                      ),
                      child: selected //0xffffc68a
                          ? Icon(
                              MdiIcons.lock,
                              color: Color(0xffffc68a), //Colors.black,
                              size: 2.4.h,
                            )
                          : Icon(
                              MdiIcons.lockOpen,
                              color: Color(0xffffc68a), //Colors.black,
                              size: 2.4.h,
                            ),
                    )
                  : Container(),
            ),
          );
        }),
      ),
      Positioned(
        top: 18.0.h,
        left: 6.08.w,
        child: Container(
          height: 88.0.w,
          width: 88.0.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey[800],
                    blurRadius: 0,
                    spreadRadius: 0.2,
                    offset: Offset(0.0, 0.0)),
              ],
              image: DecorationImage(
                  image: AssetImage("images/roundtable.jpeg"),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter)),
        ),
      ),
    ];
    for (int i = 1; i <= player_list.length; i++) {
      playerAvatar.addAll([
        circleChar(
            i.toString(), roundTrack[player_list.length][roundPass - 1], team),
        team.teams.contains(player_list[int.parse(i.toString()) - 1])
            ? Container()
            : Positioned(
                top: userLocation[i.toString()][0],
                right: userLocation[i.toString()][1],
                child: IgnorePointer(
                  ignoring: true,
                  child: ShapeOfView(
                    shape: RoundRectShape(
                      borderRadius: BorderRadius.circular(12),
                      borderColor: Colors.grey[800], //optional
                      borderWidth: 2, //optional
                    ),
                    child: Container(
                      color: Color(0xfffffff0),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          users[i - 1],
                          style: TextStyle(
                              fontFamily: 'hash',
                              fontSize: 7.5.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none),
                        ),
                      ),
                    ),
                  ),
                )),
        team.teams.contains(player_list[int.parse(i.toString()) - 1])
            ? Positioned(
                top: (movedLocation['loc' +
                            (team.teams.indexOf(
                                        player_list[
                                            int.parse(i.toString()) - 1]) +
                                    1)
                                .toString()][0] +
                        9.5.w) +
                    (18.0.h -
                            movedLocation['loc' +
                                (team.teams.indexOf(player_list[
                                            int.parse(i.toString()) - 1]) +
                                        1)
                                    .toString()][0] -
                            9.5.w) /
                        2,
                right: movedLocation['loc' +
                        (team.teams.indexOf(
                                    player_list[int.parse(i.toString()) - 1]) +
                                1)
                            .toString()][1] +
                    6.08.w -
                    (nameSpace(users[int.parse(i.toString()) - 1].length) *
                            users[int.parse(i.toString()) - 1].length)
                        .h,
                child: Text(
                  users[int.parse(i.toString()) - 1],
                  style: TextStyle(
                      fontFamily: 'hash',
                      fontSize: 10.0.sp,
                      color: Color(0xffffc68a), //Colors.black,
                      decoration: TextDecoration.none),
                ),
              )
            : Container()
      ]);
    }
    return playerAvatar;
  }

  Future<void> _showPolicyPanel(Teams team) {
    resetPolicy = false;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return WillPopScope(
              onWillPop: () {},
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter state) {
                return Container(
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(30.0),
                        topRight: const Radius.circular(30.0),
                      ),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                              alignment: Alignment.topCenter,
                              height: 8,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Color(0xffffc68a), //Colors.grey[400],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Quest Decision',
                            style: TextStyle(
                                color: Color(0xff393e46), //Colors.grey[400],
                                fontFamily: 'bondi',
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                width: 33.0.w,
                              ),
                              Text(
                                'Fail',
                                style: TextStyle(
                                    color: Color(0xff393e46), //Colors.black,
                                    fontFamily: 'hash',
                                    fontSize: 22,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none),
                              ),
                              SizedBox(
                                width: 15.0.w,
                              ),
                              Text(
                                'Pass',
                                style: TextStyle(
                                    color: Color(0xff393e46), //Colors.black,
                                    fontFamily: 'hash',
                                    fontSize: 22,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none),
                              ),
                            ],
                          ),
                          Center(
                              child: Container(
                                  child: SmartFlareActor(
                            filename: 'images/Policy.flr',
                            width: 250,
                            height: 250,
                            startingAnimation: 'activate',
                            activeAreas: [
                              ActiveArea(
                                debugArea: false,
                                area: Rect.fromLTWH(130, 40, 90, 130),
                                animationName:
                                    ['pass', 'fail'].contains(prevAnimation) ==
                                            false
                                        ? 'pass'
                                        : '',
                                onAreaTapped: () {
                                  if (['pass', 'fail']
                                          .contains(prevAnimation) ==
                                      false) {
                                    if (currUser == currentLeader) {
                                      networkRelated = false;
                                      game.updateGameQuestLock(lock: selected);
                                    }
                                    game.updateGamePolicyPass(rounds: rounds);
                                    state(() {
                                      prevAnimation = 'pass';
                                    });
                                    Timer(Duration(milliseconds: 1500), () {
                                      if (resetPolicy == false) {
                                        Navigator.of(context).pop();
                                        createPolicyDialog(context, team);
                                        resetPolicy = true;
                                      }
                                    });
                                  }
                                },
                              ),
                              ActiveArea(
                                  debugArea: false,
                                  area: Rect.fromLTWH(30, 40, 90, 130),
                                  animationName: ['pass', 'fail']
                                              .contains(prevAnimation) ==
                                          false
                                      ? 'fail'
                                      : '',
                                  onAreaTapped: () {
                                    if (['pass', 'fail']
                                            .contains(prevAnimation) ==
                                        false) {
                                      if (currUser == currentLeader) {
                                        game.updateGameQuestLock(
                                            lock: selected);
                                      }
                                      game.updateGamePolicyFail(rounds: rounds);
                                      state(() {
                                        prevAnimation = 'fail';
                                      });
                                      Timer(Duration(milliseconds: 1500), () {
                                        if (resetPolicy == false) {
                                          Navigator.of(context).pop();
                                          createPolicyDialog(context, team);
                                          resetPolicy = true;
                                        }
                                      });
                                    }
                                  })
                            ],
                          )))
                        ]));
              }));
        });
  }

  Future<void> _showVotePanel(Teams team) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return WillPopScope(
              onWillPop: () {},
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter state) {
                return Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color:
                        Color(0xff1e1e1e), //Color.fromRGBO(255, 220, 128, 1),
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(30.0),
                      topRight: const Radius.circular(30.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          alignment: Alignment.topCenter,
                          height: 8,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Color(0xffffc68a), //Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Cast Vote',
                        style: TextStyle(
                            color: Color(0xffffc68a), //Colors.white,
                            fontFamily: 'bondi',
                            fontSize: 22,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none),
                      ),
                      Center(
                        child: Container(
                            child: SmartFlareActor(
                          filename: 'images/Voted.flr',
                          width: 190,
                          height: 190,
                          startingAnimation: 'activate',
                          activeAreas: [
                            ActiveArea(
                              debugArea: false,
                              area: Rect.fromLTWH(115, 30, 70, 70),
                              animationName:
                                  ['star', 'cancel'].contains(prevAnimation) ==
                                          false
                                      ? 'star'
                                      : '',
                              onAreaTapped: () {
                                if (['star', 'cancel']
                                        .contains(prevAnimation) ==
                                    false) {
                                  resetResults = false;
                                  game.updateGameQuestAye(
                                    rounds: rounds,
                                    currUser: currUser,
                                  );
                                  state(() {
                                    prevAnimation = 'star';
                                  });
                                  Timer(Duration(milliseconds: 1500), () {
                                    Navigator.of(context).pop();
                                    _showCounterPanel(team);
                                  });
                                }
                              },
                            ),
                            ActiveArea(
                                debugArea: false,
                                area: Rect.fromLTWH(10, 30, 70, 70),
                                animationName: ['star', 'cancel']
                                            .contains(prevAnimation) ==
                                        false
                                    ? 'cancel'
                                    : '',
                                onAreaTapped: () {
                                  if (['star', 'cancel']
                                          .contains(prevAnimation) ==
                                      false) {
                                    resetResults = false;
                                    game.updateGameQuestNay(
                                        rounds: rounds, currUser: currUser);
                                    state(() {
                                      prevAnimation = 'cancel';
                                    });
                                    Timer(Duration(milliseconds: 1500), () {
                                      Navigator.of(context).pop();
                                      _showCounterPanel(team);
                                    });
                                  }
                                })
                          ],
                        )),
                      ),
                    ],
                  ),
                );
              }));
        });
  }

  // Watch out for double entry of bottom sheet in some cases
  Future<void> _showCounterPanel(Teams team) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return WillPopScope(
              onWillPop: () {},
              child: StreamProvider.value(
                  initialData: Groups(
                      ayeGroup: [], nayGroup: [], ayeCount: 0, nayCount: 0),
                  value: game.groups,
                  child:
                      Consumer<Groups>(builder: (context, Groups group, child) {
                    if (group.ayeCount + group.nayCount == player_list.length &&
                        group.nayCount >= group.ayeCount) {
                      Timer(Duration(seconds: 3), () {
                        resetStatus();
                        if (reset == false) {
                          Navigator.of(context).pop();
                          if (currUser == currentLeader) {
                            networkRelated = false;
                            game.updateGameQuest();
                            game.updateVoteTracker(
                                rounds: 'Round' + roundPass.toString());
                            game.updateGamePolicy();
                          }
                          reset = true;
                        }
                      });
                    } else if (group.ayeCount + group.nayCount ==
                            player_list.length &&
                        group.nayCount < group.ayeCount) {
                      selected = false;
                      if (team.teams.contains(currUser)) {
                        Timer(Duration(seconds: 3), () {
                          if (reset == false) {
                            Navigator.of(context).pop();
                            _showPolicyPanel(team);
                            reset = true;
                          }
                        });
                      } else {
                        Timer(Duration(seconds: 3), () {
                          if (currUser == currentLeader) {
                            networkRelated = false;
                            game.updateGameQuestLock(lock: selected);
                            game.updateGamePolicy();
                          }
                          if (reset == false) {
                            Navigator.of(context).pop();
                            createPolicyDialog(context, team);
                            reset = true;
                          }
                        });
                      }
                    }
                    return Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Color(0xff1e1e1e), //Colors.white,
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(30.0),
                          topRight: const Radius.circular(30.0),
                        ),
                      ),
                      child: Column(
                        children: getVoteTallyUsers(group),
                      ),
                    );
                  })));
        });
  }

  List<Widget> getMerlinsChoice(StateSetter merlinState) {
    List<Widget> merlinsChoice = [];
    List<Widget> players = [];
    merlinsChoice.addAll([
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          alignment: Alignment.topCenter,
          height: 8,
          width: 50,
          decoration: BoxDecoration(
            color: Color(0xffffc68a), //Colors.grey[400],
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
        ),
      ),
      SizedBox(height: 5),
      Text(
        'Identify Merlin',
        style: TextStyle(
            color: Color(0xffffc68a), //Colors.grey[400],
            fontFamily: 'bondi',
            fontSize: 25,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.none),
      ),
      SizedBox(height: 20),
    ]);
    int buttonLength =
        (users.length % 2 == 0 ? users.length : users.length - 1);
    for (int i = 0; i < buttonLength; i += 2) {
      players.add(Row(
        children: [
          SizedBox(width: 24.5.w),
          RaisedButton(
            padding: EdgeInsets.all(8),
            color: merlinChoice == i ? Color(0xffffc68a) : Color(0xff1e1e1e),
            shape: StadiumBorder(
              //borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Color(0xffffc68a)),
            ),
            onPressed: () async {
              networkRelated = false;
              merlinState(() {
                merlinChoice = i;
              });
              if (roleList[i] == 'Merlin') {
                game.updateGameQuestWinner(winner: 'evil');
              } else {
                game.updateGameQuestWinner(winner: 'good');
              }
            },
            child: Text(users[i],
                style: TextStyle(
                    color: merlinChoice == i
                        ? Color(0xff1e1e1e)
                        : Color(0xffffc68a),
                    fontSize: 12.0.sp,
                    fontFamily: 'hash')),
          ),
          SizedBox(
            width: 8.0.w,
          ),
          RaisedButton(
            padding: EdgeInsets.all(8),
            color:
                merlinChoice == i + 1 ? Color(0xffffc68a) : Color(0xff1e1e1e),
            shape: StadiumBorder(
              //borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Color(0xffffc68a)),
            ),
            onPressed: () async {
              networkRelated = false;
              merlinState(() {
                merlinChoice = i + 1;
              });
              if (roleList[i + 1] == 'Merlin') {
                game.updateGameQuestWinner(winner: 'evil');
              } else {
                game.updateGameQuestWinner(winner: 'good');
              }
            },
            child: Text(users[i + 1],
                style: TextStyle(
                    color: merlinChoice == i + 1
                        ? Color(0xff1e1e1e)
                        : Color(0xffffc68a),
                    fontSize: 12.0.sp,
                    fontFamily: 'hash')),
          ),
        ],
      ));
    }
    if (buttonLength == users.length - 1) {
      players.addAll([
        Row(children: [
          SizedBox(width: 24.5.w),
          RaisedButton(
            padding: EdgeInsets.all(8),
            color: merlinChoice == buttonLength
                ? Color(0xffffc68a)
                : Color(0xff1e1e1e),
            shape: StadiumBorder(
              //borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Color(0xffffc68a)),
            ),
            onPressed: () async {
              networkRelated = false;
              merlinState(() {
                merlinChoice = buttonLength;
              });
              if (roleList[buttonLength] == 'Merlin') {
                game.updateGameQuestWinner(winner: 'evil');
              } else {
                game.updateGameQuestWinner(winner: 'good');
              }
            },
            child: Text(users[buttonLength],
                style: TextStyle(
                    color: merlinChoice == buttonLength
                        ? Color(0xff1e1e1e)
                        : Color(0xffffc68a),
                    fontSize: 12.0.sp,
                    fontFamily: 'hash')),
          ),
        ])
      ]);
    }

    merlinsChoice.addAll(players);
    return merlinsChoice;
  }

  void showMerlinPanel() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return WillPopScope(
              onWillPop: () {},
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter merlinState) {
                return Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Color(0xff1e1e1e), //Colors.white,
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(30.0),
                        topRight: const Radius.circular(30.0),
                      ),
                    ),
                    child: Column(children: getMerlinsChoice(merlinState)));
              }));
        });
  }

  @override
  Widget build(BuildContext context) {
    ConnectivityResult connection = Provider.of<ConnectivityResult>(context);
    Size size = MediaQuery.of(context).size;
    networkRelated = true;
    print('Connectivity: ' + connection.toString());
    print('Previous: ' + modeChange.toString());
    if (connection == ConnectivityResult.none && networkRouteCheck == false) {
      networkDialog = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        createNetworkDialog(context);
      });
    } else {
      if (networkDialog && networkRouteCheck == false) {
        networkDialog = false;
        modeChange = connection;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
        });
      } else if (modeChange != connection && modeChange != null) {
        modeChange = connection;
      } else if (modeChange == null) {
        modeChange = connection;
      }
    }
    print('NetworkRelated: ' + networkRelated.toString());
    // temporary code
    return StreamProvider.value(
        initialData: Teams(locked: null, teams: [], winner: ''),
        value: game.teams,
        child: Consumer<Teams>(builder: (context, Teams team, child) {
          print("LOCKED " + team.locked.toString());
          if (team.locked == true && networkRelated == false) {
            prevAnimation = 'activate';
            if (currUser != currentLeader) {
              selected = !selected;
            }
            reset = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showVotePanel(team);
            });
          }
          if (team.locked == false && selected == true) {
            game.disconnectFromGame();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (votePass == 5 && endGame == false) {
                Timer(Duration(milliseconds: 2500), () {
                  endGame = true;
                  bool victory = charTeams[role] == 1;
                  Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, _) {
                        return SecondScreen(
                            victory: victory,
                            evilScore: evilScore,
                            goodScore: goodScore,
                            winPath: 2,
                            game: game,
                            head: head,
                            username: users[player_list.indexOf(currUser)]);
                      },
                      opaque: false));
                });
              } else {
                setState(() {
                  selected = !selected;
                  leaderIndex = (leaderIndex + 1) % player_list.length;
                  currentLeader = player_list[leaderIndex];
                  votePass += 1;
                });
              }
            });
          }

          if (team.winner != '' && endGame == false) {
            endGame = true;
            bool victory = charTeams[role] == sides[team.winner];
            game.disconnectFromGame();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, _) {
                    return SecondScreen(
                        victory: victory,
                        evilScore: evilScore,
                        goodScore: goodScore,
                        winPath: team.winner == 'evil' ? 3 : 1,
                        game: game,
                        head: head,
                        username: users[player_list.indexOf(currUser)]);
                  },
                  opaque: false));
            });
          }

          if (goodScore == 1 && merlinVote == false) {
            merlinVote = true;
            if (role == 'Mordred') {
              Timer(Duration(milliseconds: 2000), () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showMerlinPanel();
                });
              });
            } else {
              lockGame = true;
            }
          }

          if (evilScore == 3 && endGame == false) {
            game.disconnectFromGame();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Timer(Duration(milliseconds: 2500), () {
                endGame = true;
                bool victory = charTeams[role] == 1;
                Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, _) {
                      return SecondScreen(
                          victory: victory,
                          evilScore: evilScore,
                          goodScore: goodScore,
                          winPath: 1,
                          game: game,
                          head: head,
                          username: users[player_list.indexOf(currUser)]);
                    },
                    opaque: false));
              });
            });
          }

          return SafeArea(
            child: LocalHeroScope(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              child: Stack(
                overflow: Overflow.visible,
                children: [
                  Positioned.fill(
                    bottom: 0,
                    child: Container(
                        height: 15.0.h,
                        decoration: BoxDecoration(
                            color: Color(
                                0xff111111), //Color.fromRGBO(255, 220, 128, 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(
                                    0xff111111), //Color.fromRGBO(255, 220, 128, 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 1.0.h,
                                    right: 1.0.h,
                                    top: 0.923.h,
                                    bottom: 0.923.h),
                                child: Text('Round Table',
                                    style: TextStyle(
                                        color: Color(
                                            0xffffc68a), //Colors.grey[800],
                                        fontFamily: 'bondi',
                                        fontSize: 20.0.sp,
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none)),
                              ),
                            ),
                            SizedBox(height: 1.5.h),
                            Container(
                              height: 10.5.h,
                              width: 100.0.w - 12.16.w,
                              margin: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 6.2.w),
                              decoration: BoxDecoration(
                                  color: Color(0xff1e1e1e),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 1.16.h,
                                            bottom: 0,
                                            left: 7.5.w,
                                            right: 2.4.w),
                                        child: Text(
                                          'Quest Track:',
                                          style: TextStyle(
                                              fontFamily: 'hash',
                                              fontSize: 10.0.sp,
                                              color: Color(
                                                  0xffffc68a), //Colors.black,
                                              decoration: TextDecoration.none),
                                        ),
                                      ),
                                      gameCounts(
                                          roundTrack[player_list.length][0]
                                              .toString(),
                                          1,
                                          'quest',
                                          false),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts(
                                          roundTrack[player_list.length][1]
                                              .toString(),
                                          2,
                                          'quest',
                                          false),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts(
                                          roundTrack[player_list.length][2]
                                              .toString(),
                                          3,
                                          'quest',
                                          false),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      users.length > 1
                                          ? gameCounts(
                                              roundTrack[player_list.length][3]
                                                  .toString(),
                                              4,
                                              'quest',
                                              true)
                                          : gameCounts(
                                              roundTrack[player_list.length][3]
                                                  .toString(),
                                              4,
                                              'quest',
                                              false),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts(
                                          roundTrack[player_list.length][4]
                                              .toString(),
                                          5,
                                          'quest',
                                          false)
                                    ],
                                  ),
                                  SizedBox(
                                    height: 0.0.h,
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 7.5.w, right: 3.8.w),
                                        child: Text(
                                          'Vote Track:',
                                          style: TextStyle(
                                              fontFamily: 'hash',
                                              fontSize: 10.0.sp,
                                              color: Color(
                                                  0xffffc68a), //Colors.black,
                                              decoration: TextDecoration.none),
                                        ),
                                      ),
                                      gameCounts('1', 1, 'vote', false),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts('2', 2, 'vote', false),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts('3', 3, 'vote', false),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts('4', 4, 'vote', false),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts('5', 5, 'vote', false)
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        )),
                  ),
                  Positioned.fill(
                    top: 20.5.h,
                    bottom: 100.0.h - 45.0.h - 88.0.w,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xff1e1e1e), //Colors.white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40),
                              topLeft: Radius.circular(40),
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30))),
                      child: Stack(
                        overflow: Overflow.visible,
                        children: getPlayerAvatars(team),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }
}
