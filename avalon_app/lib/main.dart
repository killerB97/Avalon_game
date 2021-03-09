import 'package:avalonapp/models/player_roles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'circleReveal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/database.dart';
import 'player_list.dart';
import 'dart:math';
import 'package:avalonapp/models/player.dart';
import 'package:quiver/iterables.dart';
import 'package:get/get.dart';
import 'package:english_words/english_words.dart';
import 'package:sizer/sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:splashscreen/splashscreen.dart';
import 'screens/role_select.dart';
import 'package:avalonapp/models/settings.dart';
import 'package:avalonapp/screens/winner.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizerUtil().init(constraints, orientation);
        return MaterialApp(
          home: Avalon(),
          debugShowCheckedModeBanner: false,
          navigatorKey: Get.key,
        );
      });
    }),
  );
}

//Responsive Home Page: Done
//AlertDialog Responsive: Not Done
class Avalon extends StatefulWidget {
  @override
  _AvalonState createState() => _AvalonState();
}

class _AvalonState extends State<Avalon> {
  String generateGameKey() {
    for (WordPair i in generateWordPairs(maxSyllables: 2).take(1)) {
      return i.toString().toLowerCase();
    }
  }

  createAlertDialog(BuildContext context, var mode, String key) {
    Size size = MediaQuery.of(context).size;
    print(size.height);
    print(size.width);
    bool checkHost = false;
    bool checkJoin = true;
    bool checkUser = false;
    bool checkLock = false;
    bool firstClick = true;
    int player_no;
    TextEditingController gamekey = new TextEditingController();
    TextEditingController user = new TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
                child: Text(
              "Game Setup",
              style: TextStyle(color: Colors.grey[700]),
            )),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 2.3.h),
                      mode == 'join'
                          ? TextField(
                              onChanged: (gamekey) {
                                setState(() => mode == 'host'
                                    ? checkHost = false
                                    : checkJoin = true);
                                setState(() => checkLock = false);
                              },
                              decoration: InputDecoration(
                                  hintText: "Game Key",
                                  hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontFamily: 'vin',
                                      fontSize: 15.0.sp),
                                  errorText: mode == 'host'
                                      ? checkHost == true
                                          ? 'Game key already exists, try again'
                                          : null
                                      : checkJoin == false
                                          ? 'Game does not exist, try again'
                                          : checkLock == true
                                              ? 'Game has already started, join another'
                                              : null,
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.yellow),
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.yellow),
                                      borderRadius:
                                          BorderRadius.circular(20.0))),
                              controller: gamekey,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Column(
                                children: [
                                  Text('Game Key',
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: 'vin',
                                          fontSize: 20.0.sp)),
                                  Text(key,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'vin',
                                          fontSize: 18.0.sp)),
                                ],
                              ),
                            ),
                      SizedBox(height: 3.46.h),
                      TextField(
                        onChanged: (user) {
                          setState(() => checkUser = false);
                        },
                        decoration: InputDecoration(
                            hintText: "Username",
                            hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontFamily: 'vin',
                                fontSize: 15.0.sp),
                            errorText: checkUser == true
                                ? 'Username already exists'
                                : null,
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(20.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.yellow),
                                borderRadius: BorderRadius.circular(20.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.yellow),
                                borderRadius: BorderRadius.circular(20.0))),
                        controller: user,
                      ),
                      SizedBox(height: 3.46.h),
                      FlatButton(
                        padding: EdgeInsets.all(1.73.h),
                        color: Colors.yellow,
                        shape: StadiumBorder(
                          //borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (firstClick) {
                            DatabaseService game;
                            mode == 'host'
                                ? game = DatabaseService(game_key: key)
                                : game =
                                    DatabaseService(game_key: gamekey.text);
                            // Hosting a Game
                            if (mode == 'host') {
                              game.connectToGame();
                              checkHost = await game.checkRoom();
                              checkUser = await game.checkUserName(user.text);
                              // Check if room is already being hosted
                              if (checkHost == false && checkUser == false) {
                                await game.updateGameSettings();
                                await game.updateUserData(user.text, '1');
                                player_no = 1;
                              } else {
                                if (checkHost == true) {
                                  setState(() => checkHost = true);
                                }
                                if (checkUser == true) {
                                  setState(() => checkUser = true);
                                }
                              }
                            }

                            // Joining a Game
                            else {
                              checkJoin = await game.checkRoom();
                              print(checkJoin);
                              checkUser = await game.checkUserName(user.text);
                              print(checkUser);
                              checkLock = await game.checkLocked(gamekey.text);
                              print(checkLock);
                              if (checkJoin == true &&
                                  checkUser == false &&
                                  checkLock == false) {
                                game.connectToGame();
                                for (int i = 1; i <= 10; i += 1) {
                                  final playerCheck = await FirebaseFirestore
                                      .instance
                                      .collection(gamekey.text)
                                      .doc(i.toString())
                                      .get();

                                  if (playerCheck.exists) {
                                    continue;
                                  } else {
                                    player_no = i;
                                    print(user.text);
                                    await game.updateUserData(
                                        user.text, i.toString());
                                    break;
                                  }
                                }
                              } else {
                                if (checkJoin == false) {
                                  setState(() => checkJoin = false);
                                }
                                if (checkUser == true) {
                                  setState(() => checkUser = true);
                                }
                                if (checkLock == true) {
                                  setState(() => checkLock = true);
                                }
                              }
                            }
                            if ((checkHost == false &&
                                    checkUser == false &&
                                    mode == 'host') ||
                                (checkJoin == true &&
                                    checkUser == false &&
                                    checkLock == false &&
                                    mode == 'join')) {
                              Navigator.push(
                                context,
                                RevealRoute(
                                  page: Room(mode, game, player_no),
                                  maxRadius: size.height * 1.17,
                                  centerAlignment: Alignment.bottomRight,
                                ),
                              );
                              firstClick = false;
                            }
                          }
                        },
                        child: mode == 'host'
                            ? Text('Host',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 10.0.sp,
                                ))
                            : Text('Join',
                                style: TextStyle(color: Colors.grey[700])),
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Stack(
      children: [
        Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/bg2.jpeg"), fit: BoxFit.cover)),
            )),
        Positioned(
          top: 25.0.h,
          left: 22.0.w,
          child: Text(
            'AVALON',
            style: TextStyle(
                fontSize: 45.0.sp,
                fontFamily: 'cut',
                color: Colors.yellow,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.normal),
          ),
        ),
        Positioned(
          top: 50.0.h,
          left: 31.5.w,
          child: Column(
            children: [
              RaisedButton(
                padding: EdgeInsets.all(2.0.h),
                color: Colors.transparent,
                onPressed: () {
                  generateGameKey();
                  String key = generateGameKey();
                  DatabaseService keyCheck = DatabaseService(game_key: key);
                  while (keyCheck.checkRoom() == true) {
                    key = generateGameKey();
                    keyCheck = DatabaseService(game_key: key);
                  }
                  createAlertDialog(context, 'host', key);
                },
                child: Text('Host Game',
                    style: TextStyle(
                        color: Colors.yellow,
                        fontFamily: 'hash',
                        fontSize: 20.0.sp)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.white)),
              ),
              SizedBox(height: 3.0.h),
              RaisedButton(
                padding: EdgeInsets.all(2.0.h),
                color: Colors.transparent,
                onPressed: () {
                  createAlertDialog(context, 'join', '');
                },
                child: Text('Join Game',
                    style: TextStyle(
                        color: Colors.yellow,
                        fontFamily: 'hash',
                        fontSize: 20.0.sp)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.white)),
              ),
            ],
          ),
        )
      ],
    ));
  }
}

class Room extends StatefulWidget {
  String head;
  int player_no;
  DatabaseService game;

  Room(this.head, this.game, this.player_no);
  @override
  _RoomState createState() => _RoomState(head, game, player_no);
}

class _RoomState extends State<Room> {
  String head;
  int player_no;
  Stream<List<Player>> pl;
  DatabaseService game;
  List<String> player_list = [];
  bool exit = false;
  playerRole playerRoles;

  _RoomState(this.head, this.game, this.player_no);
  List<String> _characterCards = [
    'images/merlin.jpg',
    'images/mordred.jpg',
    'images/percival.jpg',
    'images/morgana.jpg',
    'images/knight.jpg',
    'images/oberon.jpg',
    'images/transparent.png',
    'images/minion.jpg'
  ];
  List<String> _characterNames = [
    'Merlin',
    'Mordred',
    'Percival',
    'Morgana',
    'Loyal Knight',
    'Oberon',
    '',
    'Minion'
  ];

  Map charTeams = {
    'Percival': 0,
    'Mordred': 1,
    'Merlin': 0,
    'Morgana': 1,
    'Loyal Knight': 0,
    'Oberon': 1,
    'Minion': 1
  };

  Map charReq = {
    1: [1, 0],
    2: [1, 1],
    3: [1, 2],
    5: [3, 2],
    6: [4, 2],
    7: [4, 3],
    8: [5, 3],
    9: [6, 3],
    10: [6, 4]
  };

  List<String> _characterNo = ['0', '0', '0', '0', '0', '0', '', '0'];

  List<String> _rolesList = [];

  int victCount = 0;
  int vicsCount = 0;

  int numPlayers;

  String errorText = '';

  Future<void> updateCounts(
      StateSetter updateState, int index, String oper) async {
    if (oper == 'add') {
      updateState(() {
        errorText = '';
        print('Index:' + index.toString());
        if (index <= 3 && _characterNo[index] == '1') {
          errorText =
              'You can pick atmost 1 of Merlin, Morded, Percival and Morgana';
        } else {
          _characterNo[index] =
              (int.tryParse(_characterNo[index]) + 1).toString();
        }
      });
    } else {
      updateState(() {
        errorText = '';
        if (_characterNo[index] != '0') {
          _characterNo[index] =
              (int.tryParse(_characterNo[index]) - 1).toString();
        }
      });
    }
  }

  Future<void> errorCheck(StateSetter updateState, int numPlayers) async {
    if (int.parse(_characterNo[2]) + int.parse(_characterNo[3]) == 1) {
      updateState(() {
        errorText =
            'If Percival is selected, Morgana must be selected and vice versa';
      });
    } else if (int.parse(_characterNo[0]) + int.parse(_characterNo[1]) != 2) {
      updateState(() {
        errorText = 'Merlin and Mordred are mandatory selections';
      });
    } else if ((victCount + vicsCount) != numPlayers) {
      updateState(() {
        errorText =
            'The number of players playing and characters selected must be equal';
      });
    } else if (victCount != charReq[numPlayers][0] &&
        vicsCount != charReq[numPlayers][1]) {
      updateState(() {
        errorText =
            'Incorrect number of Virtuous and Vicious characters selected';
      });
    }
  }

  List<String> getPickCriteria(int numPlayers) {
    return [
      '(Pick ' + charReq[numPlayers][0].toString() + ')',
      '(Pick ' + charReq[numPlayers][1].toString() + ')'
    ];
  }

  Future<void> _showSettingsPanel(Size size, gameSetting setting,
      int numPlayers, String pickVict, String pickVics) {
    ScrollController scrl = ScrollController();
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return WillPopScope(
            onWillPop: () {
              game.updateGameSettings(locked: false);
              Navigator.of(context).pop();
            },
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter state) {
              return Container(
                padding:
                    EdgeInsets.symmetric(vertical: 2.2.h, horizontal: 14.6.w),
                child: Column(
                  children: [
                    Text(
                      'Character Selection',
                      style: TextStyle(fontFamily: 'hash', fontSize: 20.0.sp),
                    ),
                    SizedBox(height: 2.2.h),
                    Row(
                      children: [
                        SizedBox(
                          width: 7.3.w,
                        ),
                        Text(
                          'Virtuous',
                          style:
                              TextStyle(fontFamily: 'hash', fontSize: 14.0.sp),
                        ),
                        SizedBox(
                          width: 21.0.w,
                        ),
                        Text(
                          'Vicious',
                          style:
                              TextStyle(fontFamily: 'hash', fontSize: 14.0.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.16.h),
                    Container(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 9.56.w,
                          ),
                          Text(
                            pickVict,
                            style: TextStyle(
                                fontFamily: 'hash', fontSize: 13.0.sp),
                          ),
                          SizedBox(
                            width: 24.5.w,
                          ),
                          Text(
                            pickVics,
                            style: TextStyle(
                                fontFamily: 'hash', fontSize: 13.0.sp),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 1.16.h,
                    ),
                    Expanded(
                        child: Container(
                      child: CupertinoScrollbar(
                        isAlwaysShown: true,
                        controller: scrl,
                        thickness: 1.5.w,
                        radius: Radius.circular(50.0),
                        child: GridView.count(
                            controller: scrl,
                            physics: BouncingScrollPhysics(),
                            childAspectRatio: 2.15.sp / 4.0.sp,
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.16.w,
                            mainAxisSpacing: 2.0.h,
                            padding: EdgeInsets.only(
                                top: 0.0,
                                bottom: 1.16.h,
                                left: 3.65.w,
                                right: 5.2.w),
                            children: _characterCards
                                .asMap()
                                .entries
                                .map((item) => Container(
                                      child: Card(
                                        color: Colors.transparent,
                                        elevation: 0,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _characterNames[item.key],
                                              style: TextStyle(
                                                  fontSize: 13.0.sp,
                                                  fontFamily: 'knight'),
                                            ),
                                            SizedBox(
                                              height: 0.58.h,
                                            ),
                                            Expanded(
                                              child: item.value ==
                                                      'images/transparent.png'
                                                  ? Container()
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              blurRadius: 3.0,
                                                              spreadRadius: 2.0,
                                                              offset: Offset(
                                                                  1.0,
                                                                  3.0), // shadow direction: bottom right
                                                            )
                                                          ],
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  item.value),
                                                              fit: BoxFit.cover,
                                                              alignment: Alignment
                                                                  .topCenter)),
                                                      child: Stack(
                                                        overflow:
                                                            Overflow.visible,
                                                        children: [
                                                          Positioned(
                                                              bottom: 2,
                                                              right: 2,
                                                              child: Container(
                                                                height: 3.46.h,
                                                                width: 3.46.h,
                                                                child: Material(
                                                                  elevation: 2,
                                                                  // pause button (round)
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50), // change radius size
                                                                  color: Colors
                                                                      .white, //button colour
                                                                  child: Icon(
                                                                    Icons
                                                                        .add_rounded,
                                                                    size:
                                                                        17.0.sp,
                                                                    color: Colors
                                                                            .grey[
                                                                        800],
                                                                  ),
                                                                ),
                                                              )),
                                                          Positioned(
                                                            bottom: 0,
                                                            right: 0,
                                                            child: Container(
                                                              height: 5.2.h,
                                                              width: 5.2.h,
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                // inkwell onPress colour
                                                                onTap: () {
                                                                  _rolesList.add(
                                                                      _characterNames[
                                                                          item.key]);
                                                                  if (charTeams[
                                                                          _characterNames[
                                                                              item.key]] ==
                                                                      0) {
                                                                    victCount++;
                                                                  } else {
                                                                    vicsCount++;
                                                                  }
                                                                  updateCounts(
                                                                      state,
                                                                      item.key,
                                                                      'add');
                                                                }, // or use onPressed: () {}
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                              bottom: 2,
                                                              left: 2,
                                                              child: Container(
                                                                height: 3.46.h,
                                                                width: 3.46.h,
                                                                child: Material(
                                                                  elevation: 2,
                                                                  // pause button (round)
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              50), // change radius size
                                                                  color: Colors
                                                                      .white, //button colour
                                                                  child: Icon(
                                                                    Icons
                                                                        .remove_rounded,
                                                                    size:
                                                                        17.0.sp,
                                                                    color: Colors
                                                                            .grey[
                                                                        800],
                                                                  ),
                                                                ),
                                                              )),
                                                          Positioned(
                                                            bottom: 0,
                                                            left: 0,
                                                            child: Container(
                                                              height: 5.2.h,
                                                              width: 5.2.h,
                                                              color: Colors
                                                                  .transparent,
                                                              child: InkWell(
                                                                // inkwell onPress colour
                                                                onTap: () {
                                                                  _rolesList.remove(
                                                                      _characterNames[
                                                                          item.key]);
                                                                  if (charTeams[
                                                                          _characterNames[
                                                                              item.key]] ==
                                                                      0) {
                                                                    victCount--;
                                                                  } else {
                                                                    vicsCount--;
                                                                  }
                                                                  updateCounts(
                                                                      state,
                                                                      item.key,
                                                                      'sub');
                                                                }, // or use onPressed: () {}
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )),
                                            ),
                                            SizedBox(
                                              height: 0.58.h,
                                            ),
                                            Text(
                                              _characterNo[item.key],
                                              style: TextStyle(
                                                  fontSize: 13.0.sp,
                                                  fontFamily: 'hash'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList()),
                      ),
                    )),
                    SizedBox(
                      height: 2.3.h,
                    ),
                    Row(
                      children: [
                        errorText == ''
                            ? Container()
                            : FaIcon(
                                FontAwesomeIcons.exclamationCircle,
                                color: Colors.redAccent,
                                size: 16.0.sp,
                              ),
                        SizedBox(width: 2.5.w),
                        Flexible(
                          child: Text(errorText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10.0.sp,
                                color: Colors.redAccent,
                              )),
                        )
                      ],
                    ),
                    SizedBox(height: 3.46.h),
                    RaisedButton(
                      padding: EdgeInsets.all(10),
                      color: Colors.yellow,
                      shape: StadiumBorder(
                        //borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.yellowAccent),
                      ),
                      onPressed: () async {
                        if (numPlayers == _rolesList.length) {
                          errorCheck(state, numPlayers);
                          if (errorText == '') {
                            playerRoles = await game.allocateRole(_rolesList);
                            int seed = Random().nextInt(numPlayers);
                            game.updateGameSettings(
                                start: true,
                                locked: true,
                                numPlayers: numPlayers,
                                seed: seed);
                            Navigator.push(
                              context,
                              RevealRoute(
                                page: Loading(
                                    size,
                                    playerRoles.role_list,
                                    game,
                                    setting,
                                    head,
                                    player_no,
                                    playerRoles.player_list,
                                    seed),
                                maxRadius: size.height * 1.17,
                                centerAlignment: Alignment.bottomCenter,
                              ),
                            );
                          }
                        } else {
                          errorCheck(state, numPlayers);
                        }
                      },
                      child: Text('Start Game',
                          style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 18.2.sp,
                              fontFamily: 'knight')),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

  Future<bool> _onBackPressed(BuildContext context, String mode) {
    Size size = MediaQuery.of(context).size;
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Padding(
              padding: const EdgeInsets.all(10.0),
              child: new Text('Do you want to exit the room?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    "No",
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 10),
              new GestureDetector(
                onTap: () {
                  mode == 'host'
                      ? game.deleteCollection()
                      : game.deleteDocument(player_no);
                  Navigator.pushAndRemoveUntil(
                      context,
                      RevealRoute(
                        page: Avalon(),
                        maxRadius: size.height * 1.17,
                        centerAlignment: Alignment.bottomCenter,
                      ),
                      ModalRoute.withName('/'));
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                  child: Text(
                    "Yes",
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return StreamProvider.value(
      initialData:
          gameSetting(locked: false, start: false, no_player: 0, seed: 0),
      value: game.settings,
      child:
          Consumer<gameSetting>(builder: (context, gameSetting setting, child) {
        if (setting.start == true && head == 'join') {
          return Loading(size, _rolesList, game, setting, head, player_no,
              player_list, setting.seed);
        } else {
          return StreamProvider<List<Player>>.value(
            initialData: [Player(player_no: 0, username: 'default')],
            value: game.players,
            child: Consumer<List<Player>>(
                builder: (context, List<Player> player, child) {
              if (player.length == 0 && exit == false) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  exit = true;
                  Navigator.pushAndRemoveUntil(
                      context,
                      RevealRoute(
                        page: Avalon(),
                        maxRadius: size.height * 1.17,
                        centerAlignment: Alignment.bottomCenter,
                      ),
                      ModalRoute.withName('/'));
                  // executes after build
                });
                return Container();
              } else {
                return SafeArea(
                    child: Container(
                  child: Stack(children: [
                    Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("images/bg2.jpeg"),
                                  fit: BoxFit.fitHeight)),
                        )),
                    Container(
                        height: 12.5.h,
                        decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey[800],
                                  blurRadius: 10.0,
                                  offset: Offset(0.0, 0.5)),
                            ],
                            color: Colors.yellow,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0))),
                        //color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                FlatButton(
                                    color: Colors.yellow,
                                    onPressed: () {
                                      _onBackPressed(context, head);
                                    },
                                    child: Icon(Icons.exit_to_app_rounded,
                                        size: 6.5.w, color: Colors.grey[800])),
                                SizedBox(width: 5.5.w),
                                Text(
                                  'Knights in waiting',
                                  style: TextStyle(
                                      fontSize: 8.0.w,
                                      fontFamily: 'knight',
                                      color: Colors.grey[800],
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Game Key: ',
                                  style: TextStyle(
                                      fontSize: 6.0.w,
                                      fontFamily: 'vin',
                                      color: Colors.grey[600],
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal),
                                ),
                                Text(
                                  game.game_key,
                                  style: TextStyle(
                                      fontSize: 6.0.w,
                                      fontFamily: 'vin',
                                      color: Colors.grey[800],
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Positioned(
                      top: 17.0.h,
                      bottom: 14.0.h,
                      right: 0.0,
                      left: 0.0,
                      child: playerList(game),
                    ),
                    head == 'host'
                        ? Positioned(
                            bottom: 30,
                            left: 34.5.w,
                            child: FlatButton.icon(
                              icon: Icon(
                                Icons.lock,
                                color: Colors.grey[800],
                                size: 3.8.h,
                              ),
                              padding: EdgeInsets.only(
                                  left: 4.2.w,
                                  right: 4.2.w,
                                  top: 1.5.h,
                                  bottom: 1.5.h),
                              color: Colors.yellow,
                              shape: StadiumBorder(
                                //borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.yellowAccent),
                              ),
                              onPressed: () async {
                                numPlayers = await game.getNumberPlayers();
                                List<String> pickCriteria =
                                    getPickCriteria(numPlayers);
                                // Minimum number of players is 5
                                if (numPlayers > 0) {
                                  game.updateGameSettings(
                                      locked: true, numPlayers: numPlayers);
                                  _showSettingsPanel(size, setting, numPlayers,
                                      pickCriteria[0], pickCriteria[1]);
                                }
                              },
                              label: Text('Lock',
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 26.0.sp,
                                      fontFamily: 'knight',
                                      fontWeight: FontWeight.normal)),
                            ),
                          )
                        : Container(),
                  ]),
                ));
              }
            }),
          );
        }
      }),
    );
  }
}

class Loading extends StatefulWidget {
  Size size;
  List<String> roleSelect;
  DatabaseService game;
  gameSetting setting;
  String head;
  int player_no;
  List<String> player_list;
  int seed;

  Loading(this.size, this.roleSelect, this.game, this.setting, this.head,
      this.player_no, this.player_list, this.seed);
  @override
  _LoadingState createState() => _LoadingState(
      size, roleSelect, game, setting, head, player_no, player_list, seed);
}

class _LoadingState extends State<Loading> {
  Size size;
  List<String> roleSelect;
  DatabaseService game;
  gameSetting setting;
  String head;
  int player_no;
  int seed;
  List<String> shuffled_player_list = [];
  List<String> shuffled_roleSelect = [];
  List<String> player_list;
  _LoadingState(this.size, this.roleSelect, this.game, this.setting, this.head,
      this.player_no, this.player_list, this.seed);

  void shufflePlayerOrder(int seed) {
    int rotate = 0;
    for (int i = 0; i < player_list.length; i++) {
      rotate = (rotate + seed) % player_list.length;
      shuffled_player_list.add(player_list[rotate]);
      shuffled_roleSelect.add(roleSelect[rotate]);
    }
    print('seed ' + seed.toString());
    print('JAGGER');
    print(player_list);
    print(roleSelect);
    print('MAC');
    print(shuffled_player_list);
    print(shuffled_roleSelect);
  }

  void setRolesList(gameSetting setting) async {
    int docid = 1;
    while (roleSelect.length != setting.no_player) {
      var role = await game.getCharacterName((docid).toString());
      if (role != null) {
        roleSelect.add(role);
        player_list.add(docid.toString());
      }
      docid++;
    }
    if (seed == 0) {
      shuffled_player_list = player_list;
      shuffled_roleSelect = roleSelect;
    } else {
      shufflePlayerOrder(seed);
    }
  }

  startTime() async {
    if (head == 'join' && roleSelect.length == 0) {
      setRolesList(setting);
    }
    if (head == 'host') {
      shufflePlayerOrder(seed);
      game.updateGameQuest();
      game.voteTracker(rounds: 'Round1');
      game.updateGamePolicy();
    }
    var duration = new Duration(seconds: 7);
    return new Timer(duration, route);
  }

  void initState() {
    super.initState();
    startTime();
  }

  route() {
    Navigator.pushAndRemoveUntil(
        context,
        RevealRoute(
          page: roleSelection(
              shuffled_roleSelect, player_no, shuffled_player_list, game, head),
          maxRadius: size.height * 1.46,
          centerAlignment: Alignment.centerRight,
        ),
        ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {},
      child: SplashScreen(
        seconds: 10,
        backgroundColor: Color.fromRGBO(14, 18, 23, 1),
        image: Image.asset('images/loader1.gif'),
        loaderColor: Color.fromRGBO(14, 18, 23, 1),
        photoSize: 17.32.h,
        title: Text('Starting Game',
            style: TextStyle(
                fontFamily: 'goldsmith', fontSize: 5.0.h, color: Colors.white)),
      ),
    );
  }
}
