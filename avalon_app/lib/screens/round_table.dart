import 'package:avalonapp/models/teams.dart';
import 'package:avalonapp/player_list.dart';
import 'package:avalonapp/services/database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:avalonapp/special_widgets/cool_switch.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:avalonapp/models/groups.dart';
import 'package:avalonapp/models/policy.dart';
import 'package:smart_flare/smart_flare.dart';
//import 'package:avalonapp/special_widgets/circle_char.dart';
import 'package:collection/collection.dart';
import 'package:local_hero/local_hero.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:shape_of_view/shape_of_view.dart';
import 'dart:async';
import 'dart:math';

class roundTable extends StatefulWidget {
  List<String> player_list;
  String head;
  List<String> users;
  String currUser;
  DatabaseService game;
  roundTable(this.player_list, this.head, this.users, this.currUser, this.game);
  @override
  _roundTableState createState() =>
      _roundTableState(player_list, head, users, currUser, game);
}

class _roundTableState extends State<roundTable> {
  List<String> player_list;
  String head;
  String flag;
  String prevAnimation = 'activate';
  Function eq = const ListEquality().equals;
  _roundTableState(
      this.player_list, this.head, this.users, this.currUser, this.game);
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
  bool policyTrans = false;
  bool stopPolicyState = false;
  ValueNotifier<bool> error = ValueNotifier<bool>(false);
  int errorMessage = 0;
  String currentLeader;
  List<String> users;
  //List<String> users = ['Dot', 'Sid', 'Sachin', 'DB', 'Vin'];
  /* 'Shourya',
    'KC',
    'Jatin',
    'Hamza',
    'Nishanth',
    'Sid',
    'Suso'*/
  List<String> deck = [];

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
    5: [2, 3, 2, 3, 3],
    6: [2, 3, 4, 3, 4],
    7: [2, 3, 3, 4, 4],
    8: [3, 4, 4, 5, 5],
    9: [3, 4, 4, 5, 5],
    10: [3, 4, 4, 5, 5]
  };

  @override
  void initState() {
    currentLeader = player_list[0];
    super.initState();
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
    final FlareControls controls = FlareControls();
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
                    fontFamily: 'cut',
                    fontSize: 25,
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
                      print(team.teams.length);
                      print(pol.passCount);
                      print(pol.failCount);
                      if (pol.passCount + pol.failCount == team.teams.length &&
                          stopPolicyState == false) {
                        horse = 'success';
                        stopPolicyState = true;
                        print(resetResults);
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
                            if (currUser == currentLeader) {
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
                              roundStatus[roundPass - 1] =
                                  pol.failCount >= 1 ? 'fail' : 'pass';
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
      top: player_no == currentLeader
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
      right: player_no == currentLeader
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
                teams.teams.length <= teamStrength) {
              for (int slot = 1; slot <= 5; slot++) {
                if (CharStatus[player_no] != 'None') {
                  if (teams.teams.length == teamStrength) {
                    callback('sub');
                  } else {
                    callback('sub_lock');
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
                      callback('add');
                      break;
                    } else {
                      callback('add_lock');
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
          child: currentLeader == player_no
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
                  backgroundColor: currentLeader != player_no
                      ? Colors.grey[100]
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

  Widget gameCounts(String numb, int sel, String track) {
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
                          ? (votePass == sel ? Colors.white : Color(0xffffe7a6))
                          : (roundPass == sel
                              ? Colors.white
                              : Color(0xffffe7a6)),
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: Center(
                    child: Text(numb,
                        style: TextStyle(
                            fontFamily: 'hash',
                            fontSize: 12.0.sp,
                            color: Colors.black,
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
                      ? (votePass == sel ? Colors.white : Color(0xffffe7a6))
                      : (roundPass == sel ? Colors.white : Color(0xffffe7a6)),
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Center(
                child: Text(numb,
                    style: TextStyle(
                        fontFamily: 'hash',
                        fontSize: 12.0.sp,
                        color: Colors.black,
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
            color: Colors.grey[400],
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
            width: 100,
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
                color: Colors.grey[800],
                fontFamily: 'hash',
                fontSize: 15,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none),
          ),
          SizedBox(
            width: 150,
          ),
          Text(
            group.nayCount.toInt().toString(),
            style: TextStyle(
                color: Colors.grey[800],
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
              width: (125 -
                      users[player_list.indexOf(group.ayeGroup[i])].length * 5)
                  .toDouble(),
            ),
            Text(
              users[player_list.indexOf(group.ayeGroup[i])],
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'hash',
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none),
            ),
            SizedBox(
                width: (100 +
                        (185 -
                                users[player_list.indexOf(group.nayGroup[i])]
                                        .length *
                                    5)
                            .toDouble()) -
                    ((125 -
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
                  color: Colors.black,
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
                width: (125 -
                        users[player_list.indexOf(group.ayeGroup[j])].length *
                            5)
                    .toDouble(),
              ),
              Text(
                users[player_list.indexOf(group.ayeGroup[j])],
                style: TextStyle(
                    color: Colors.black,
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
                width: 100,
              ),
              SizedBox(
                width: (185 -
                        users[player_list.indexOf(group.nayGroup[j])].length *
                            5)
                    .toDouble(),
              ),
              Text(
                users[player_list.indexOf(group.nayGroup[j])],
                style: TextStyle(
                    color: Colors.black,
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
                color: Colors.black,
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
              onTap: () {
                if (team.teams.length !=
                    roundTrack[player_list.length][roundPass - 1]) {
                  callback('lock');
                } else {
                  iconState(() {
                    selected = !selected;
                  });
                  game.updateGameQuestLock(lock: selected);
                  //game.updateVoteTracker(rounds: rounds);
                }
              },
              child: currUser == currentLeader
                  ? Container(
                      height: 3.66.h,
                      width: 3.66.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey[800],
                              blurRadius: 0,
                              spreadRadius: 0.0,
                              offset: Offset(0.0, 0.0)),
                        ],
                      ),
                      child: selected
                          ? Icon(
                              Icons.lock_rounded,
                              color: Colors.black,
                              size: 2.92.h,
                            )
                          : Icon(
                              Icons.lock_open_rounded,
                              color: Colors.black,
                              size: 2.92.h,
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
                    (0.33 * users[int.parse(i.toString()) - 1].length).h,
                child: Text(
                  users[int.parse(i.toString()) - 1],
                  style: TextStyle(
                      fontFamily: 'hash',
                      fontSize: 10.0.sp,
                      color: Colors.black,
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
                                color: Colors.grey[400],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Quest Decision',
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontFamily: 'cut',
                                fontSize: 25,
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
                                    color: Colors.black,
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
                                    color: Colors.black,
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
                                    game.updateGamePolicyPass(rounds: rounds);
                                    state(() {
                                      prevAnimation = 'pass';
                                    });
                                    Timer(Duration(milliseconds: 1500), () {
                                      if (resetPolicy == false) {
                                        resetResults = false;
                                        if (currUser == currentLeader) {
                                          game.updateGameQuestLock(
                                              lock: selected);
                                        }
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
                                      game.updateGamePolicyFail(rounds: rounds);
                                      state(() {
                                        prevAnimation = 'fail';
                                      });
                                      Timer(Duration(milliseconds: 1500), () {
                                        if (resetPolicy == false) {
                                          resetResults = false;
                                          if (currUser == currentLeader) {
                                            game.updateGameQuestLock(
                                                lock: selected);
                                          }
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
                    color: Color.fromRGBO(255, 220, 128, 1),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Cast Vote',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'cut',
                            fontSize: 25,
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
    reset = false;
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
                    print(group.ayeCount);
                    print(group.nayCount);
                    if (group.ayeCount + group.nayCount == player_list.length &&
                        group.nayCount >= group.ayeCount) {
                      Timer(Duration(seconds: 3), () {
                        if (reset == false) {
                          if (currUser == currentLeader) {
                            game.updateGameQuest();
                            game.updateVoteTracker(
                                rounds: 'Round' + roundPass.toString());
                            game.updateGamePolicy();
                          }
                          Navigator.of(context).pop();
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
                        color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    // temporary code
    return StreamProvider.value(
        initialData: Teams(teams: []),
        value: game.teams,
        child: Consumer<Teams>(builder: (context, Teams team, child) {
          if (team.locked == true) {
            prevAnimation = 'activate';
            if (currUser != currentLeader) {
              selected = !selected;
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showVotePanel(team);
            });
          }
          if (team.locked == false && selected == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                selected = !selected;
                leaderIndex = (leaderIndex + 1) % player_list.length;
                reset = false;
                currentLeader = player_list[leaderIndex];
                votePass += 1;
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
                            color: Color.fromRGBO(255, 220, 128, 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 220, 128, 1),
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
                                        color: Colors.grey[800],
                                        fontFamily: 'hash',
                                        fontSize: 22.0.sp,
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
                                  color: Color(0xffffe7a6),
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
                                              color: Colors.black,
                                              decoration: TextDecoration.none),
                                        ),
                                      ),
                                      gameCounts(
                                          roundTrack[player_list.length][0]
                                              .toString(),
                                          1,
                                          'quest'),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts(
                                          roundTrack[player_list.length][1]
                                              .toString(),
                                          2,
                                          'quest'),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts(
                                          roundTrack[player_list.length][2]
                                              .toString(),
                                          3,
                                          'quest'),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts(
                                          roundTrack[player_list.length][3]
                                              .toString(),
                                          4,
                                          'quest'),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts(
                                          roundTrack[player_list.length][4]
                                              .toString(),
                                          5,
                                          'quest')
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
                                              color: Colors.black,
                                              decoration: TextDecoration.none),
                                        ),
                                      ),
                                      gameCounts('1', 1, 'vote'),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts('2', 2, 'vote'),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts('3', 3, 'vote'),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts('4', 4, 'vote'),
                                      SizedBox(
                                        width: 1.5.w,
                                      ),
                                      gameCounts('5', 5, 'vote')
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
                          color: Colors.white,
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
