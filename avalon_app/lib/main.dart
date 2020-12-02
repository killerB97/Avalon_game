import 'package:avalonapp/playertile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'circleReveal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/database.dart';
import 'player_list.dart';
import 'package:avalonapp/models/player.dart';
import 'package:get/get.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(Phoenix(
    child: MaterialApp(
      home: Avalon(),
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
    ),
  ));
}

class Avalon extends StatefulWidget {
  @override
  _AvalonState createState() => _AvalonState();
}

class _AvalonState extends State<Avalon> {
  createAlertDialog(BuildContext context, var mode) {
    Size size = MediaQuery.of(context).size;
    bool checkHost = false;
    bool checkJoin = true;
    bool checkUser = false;
    int player_no;
    TextEditingController gamekey = new TextEditingController();
    TextEditingController user = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
                child: Text(
              'Game Setup',
              style: TextStyle(color: Colors.grey[700]),
            )),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20),
                    TextField(
                      onChanged: (gamekey) {
                        setState(() => mode == 'host'
                            ? checkHost = false
                            : checkJoin = true);
                      },
                      decoration: InputDecoration(
                          hintText: "Game Key",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          errorText: mode == 'host'
                              ? checkHost == true
                                  ? 'Game key already exists, try again'
                                  : null
                              : checkJoin == false
                                  ? 'Game does not exist, try again'
                                  : null,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.yellow),
                              borderRadius: BorderRadius.circular(20.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.yellow),
                              borderRadius: BorderRadius.circular(20.0))),
                      controller: gamekey,
                    ),
                    SizedBox(height: 30),
                    TextField(
                      onChanged: (user) {
                        setState(() => checkUser = false);
                      },
                      decoration: InputDecoration(
                          hintText: "Username",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          errorText: checkUser == true
                              ? 'Username already exists, please try again'
                              : null,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.yellow),
                              borderRadius: BorderRadius.circular(20.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.yellow),
                              borderRadius: BorderRadius.circular(20.0))),
                      controller: user,
                    ),
                    SizedBox(height: 20),
                    FlatButton(
                      padding: EdgeInsets.all(15.0),
                      color: Colors.yellow,
                      shape: StadiumBorder(
                        //borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white),
                      ),
                      onPressed: () async {
                        DatabaseService game =
                            DatabaseService(game_key: gamekey.text);

                        // Hosting a Game
                        if (mode == 'host') {
                          game.connectToGame();
                          checkHost = await game.checkRoom();
                          checkUser = await game.checkUserName(user.text);
                          // Check if room is already being hosted
                          if (checkHost == false && checkUser == false) {
                            await game.updateUserData(user.text, '1');
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
                          checkUser = await game.checkUserName(user.text);
                          print(checkUser);
                          print(checkJoin);
                          if (checkJoin == true && checkUser == false) {
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
                          }
                        }
                        if ((checkHost == false &&
                                checkUser == false &&
                                mode == 'host') ||
                            (checkJoin == true &&
                                checkUser == false &&
                                mode == 'join')) {
                          print('yes');
                          Navigator.push(
                            context,
                            RevealRoute(
                              page: Room(mode, game, player_no),
                              maxRadius: size.height * 1.17,
                              centerAlignment: Alignment.bottomRight,
                            ),
                          );
                        }
                      },
                      child: mode == 'host'
                          ? Text('Host',
                              style: TextStyle(color: Colors.grey[700]))
                          : Text('Join',
                              style: TextStyle(color: Colors.grey[700])),
                    )
                  ],
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
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/bg1.jpg"),
                      fit: BoxFit.fitHeight)),
            )),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(80.0),
            child: Text('AVALON',
                style: TextStyle(
                    fontSize: 60,
                    fontFamily: 'wp',
                    color: Color.fromRGBO(215, 183, 64, 1),
                    decoration: TextDecoration.none),
                textAlign: TextAlign.center),
          ),
        ),
        Positioned(
          top: size.height * 0.45,
          left: size.width * 0.30,
          child: Column(
            children: [
              RaisedButton(
                padding: EdgeInsets.all(15.0),
                color: Colors.transparent,
                onPressed: () {
                  createAlertDialog(context, 'host');
                },
                child: Text('Host Game',
                    style: TextStyle(
                        color: Colors.yellow,
                        fontFamily: 'hash',
                        fontSize: 30.0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.white)),
              ),
              SizedBox(height: 30.0),
              RaisedButton(
                padding: EdgeInsets.all(15.0),
                color: Colors.transparent,
                onPressed: () {
                  createAlertDialog(context, 'join');
                },
                child: Text('Join Game',
                    style: TextStyle(
                        color: Colors.yellow,
                        fontFamily: 'hash',
                        fontSize: 30.0)),
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
  _RoomState(this.head, this.game, this.player_no);
  List<String> _characterCards = [
    'images/percival.jpg',
    'images/mordred.png',
    'images/merlin.png',
    'images/morgana.jpg',
    'images/knight.jpg',
    'images/oberon.jpg',
    'images/transparent.png',
    'images/minion.jpg'
  ];
  List<String> _characterNames = [
    'Percival',
    'Mordred',
    'Merlin',
    'Morgana',
    'Loyal Knight',
    'Oberon',
    '',
    'Minion'
  ];
  List<String> _characterNo = ['0', '0', '0', '0', '0', '0', '', '0'];

  List<String> _rolesList = [];

  Future<void> updateCounts(
      StateSetter updateState, int index, String oper) async {
    if (oper == 'add') {
      updateState(() {
        _characterNo[index] =
            (int.tryParse(_characterNo[index]) + 1).toString();
      });
    } else {
      updateState(() {
        if (_characterNo[index] != '0') {
          _characterNo[index] =
              (int.tryParse(_characterNo[index]) - 1).toString();
        }
      });
    }
    print(_rolesList);
  }

  void _showSettingsPanel() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter state) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
              child: Column(
                children: [
                  Text(
                    'Character Selection',
                    style: TextStyle(fontFamily: 'hash', fontSize: 30),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                      ),
                      Text(
                        'Virtuous',
                        style: TextStyle(fontFamily: 'hash', fontSize: 20),
                      ),
                      SizedBox(
                        width: 85,
                      ),
                      Text(
                        'Vicious',
                        style: TextStyle(fontFamily: 'hash', fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: Container(
                    child: GridView.count(
                        physics: BouncingScrollPhysics(),
                        childAspectRatio: 5 / 10,
                        crossAxisCount: 2,
                        crossAxisSpacing: 50,
                        mainAxisSpacing: 30,
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, left: 15, right: 15),
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
                                              fontSize: 18.0,
                                              fontFamily: 'knight'),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                          child: item.value ==
                                                  'images/transparent.png'
                                              ? Container()
                                              : Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey,
                                                          blurRadius: 3.0,
                                                          spreadRadius: 2.0,
                                                          offset: Offset(1.0,
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
                                                    overflow: Overflow.visible,
                                                    children: [
                                                      Positioned(
                                                          top: 119,
                                                          left: 66,
                                                          child: Container(
                                                            height: 30,
                                                            width: 30,
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
                                                                Icons.add,
                                                                color: Colors
                                                                    .grey[800],
                                                              ),
                                                            ),
                                                          )),
                                                      Positioned(
                                                        top: 110,
                                                        left: 55,
                                                        child: Container(
                                                          height: 50,
                                                          width: 50,
                                                          color: Colors
                                                              .transparent,
                                                          child: InkWell(
                                                            // inkwell onPress colour
                                                            onTap: () {
                                                              _rolesList.add(
                                                                  _characterNames[
                                                                      item.key]);
                                                              updateCounts(
                                                                  state,
                                                                  item.key,
                                                                  'add');
                                                            }, // or use onPressed: () {}
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                          top: 119,
                                                          left: 2,
                                                          child: Container(
                                                            height: 30,
                                                            width: 30,
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
                                                                Icons.remove,
                                                                color: Colors
                                                                    .grey[800],
                                                              ),
                                                            ),
                                                          )),
                                                      Positioned(
                                                        top: 110,
                                                        left: -5,
                                                        child: Container(
                                                          height: 50,
                                                          width: 50,
                                                          color: Colors
                                                              .transparent,
                                                          child: InkWell(
                                                            // inkwell onPress colour
                                                            onTap: () {
                                                              _rolesList.remove(
                                                                  _characterNames[
                                                                      item.key]);
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
                                          height: 5,
                                        ),
                                        Text(
                                          _characterNo[item.key],
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: 'hash'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList()),
                  )),
                  SizedBox(
                    height: 30,
                  ),
                  RaisedButton(
                    padding: EdgeInsets.all(10.0),
                    color: Colors.yellow,
                    shape: StadiumBorder(
                      //borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.yellowAccent),
                    ),
                    onPressed: () {},
                    child: Text('Start Game',
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 25,
                            fontFamily: 'knight')),
                  ),
                ],
              ),
            );
          });
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
                  Navigator.push(
                    context,
                    RevealRoute(
                      page: Avalon(),
                      maxRadius: size.height * 1.17,
                      centerAlignment: Alignment.bottomRight,
                    ),
                  );
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
    return StreamProvider<List<Player>>.value(
      initialData: [Player(player_no: 0, username: 'default')],
      value: game.players,
      child: Consumer<List<Player>>(
          builder: (context, List<Player> player, child) {
        if (player.length == 0) {
          return Avalon();
        } else {
          return SafeArea(
              child: Container(
            child: Stack(children: [
              Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/bg1.jpg"),
                            fit: BoxFit.fitHeight)),
                  )),
              Container(
                  height: (size.height) / 8,
                  decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey[800],
                            blurRadius: 10.0,
                            offset: Offset(0.0, 0.5)),
                      ],
                      color: Colors.yellow,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0))),
                  //color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FlatButton(
                          color: Colors.yellow,
                          onPressed: () {
                            _onBackPressed(context, head);
                          },
                          child: Icon(Icons.exit_to_app_rounded,
                              size: 30.0, color: Colors.grey[800])),
                      SizedBox(width: size.width / 25),
                      Text(
                        'Knights in waiting',
                        style: TextStyle(
                            fontSize: 35,
                            fontFamily: 'knight',
                            color: Colors.grey[800],
                            decoration: TextDecoration.none),
                      ),
                    ],
                  )),
              Positioned(
                top: 150.0,
                bottom: 125.0,
                right: 0.0,
                left: 0.0,
                child: playerList(game),
              ),
              head == 'host'
                  ? Positioned(
                      bottom: 30,
                      left: 144,
                      child: FlatButton(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        color: Colors.yellow,
                        shape: StadiumBorder(
                          //borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.yellowAccent),
                        ),
                        onPressed: () {
                          _showSettingsPanel();
                        },
                        child: Text('Setup',
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 40,
                                fontFamily: 'knight')),
                      ),
                    )
                  : Container(),
            ]),
          ));
        }
      }),
    );
  }
}
