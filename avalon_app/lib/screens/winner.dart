import 'package:avalonapp/services/database.dart';
import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/services.dart';
import 'package:avalonapp/circleReveal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sizer/sizer.dart';
import 'package:avalonapp/main.dart';

class SecondScreen extends StatelessWidget {
  bool victory;
  int evilScore;
  int goodScore;
  int winPath;
  DatabaseService game;
  String head;
  String username;
  SecondScreen(
      {this.victory,
      this.evilScore,
      this.goodScore,
      this.winPath,
      this.game,
      this.head,
      this.username});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              child: TweenAnimationBuilder(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 2800),
                  builder: (context, value, child) {
                    return ShaderMask(
                        shaderCallback: (rect) {
                          return RadialGradient(
                                  radius: value * 5,
                                  colors: [
                                    Colors.white,
                                    Colors.white,
                                    Colors.transparent,
                                    Colors.transparent
                                  ],
                                  stops: [0.0, 0.55, 0.6, 1.0],
                                  center: FractionalOffset(0.95, 0.95))
                              .createShader(rect);
                        },
                        child: Winner(
                            victory: victory,
                            evilScore: evilScore,
                            winPath: winPath,
                            goodScore: goodScore,
                            game: game,
                            head: head,
                            username: username));
                  }),
            );
          },
        ));
  }
}

class Winner extends StatelessWidget {
  bool victory;
  int evilScore;
  int goodScore;
  int winPath;
  DatabaseService game;
  String head;
  String username;
  Winner(
      {this.victory,
      this.evilScore,
      this.goodScore,
      this.winPath,
      this.game,
      this.head,
      this.username})
      : winMessage = {
          1: 'Vicious    Virtuous\n$evilScore    ' + ' - ' + '     $goodScore',
          2: 'Failed Votes exceeded 5',
          3: 'Merlin was identified correctly'
        };
  Map winMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: 100.0.h,
          width: 100.0.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: victory == false
                    ? [Color(0xff2c061f), Color(0xff91091e)]
                    : [Color(0xff48426d), Color(0xff09015f)]),
            image: DecorationImage(
              alignment: Alignment.center,
              image: victory == true
                  ? AssetImage('images/win.gif')
                  : AssetImage('images/defeat.gif'),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 15.0.h,
              ),
              Text(
                winMessage[winPath],
                style: TextStyle(
                    color:
                        victory == true ? Color(0xfff3ecf8) : Color(0xffffe5e6),
                    fontFamily: 'bondi',
                    fontSize: winPath == 1 ? 25.0.sp : 20.0.sp,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FabCircularMenu(
          alignment: Alignment.bottomCenter,
          ringDiameter: 200,
          fabElevation: 10,
          fabSize: 60,
          fabOpenIcon: RotationTransition(
              turns: AlwaysStoppedAnimation(0 / 360),
              child: Icon(
                MdiIcons.nintendoSwitch,
                size: 27,
                color: Colors.grey[900],
              )),
          fabCloseIcon: RotationTransition(
              turns: AlwaysStoppedAnimation(45 / 360),
              child: Icon(
                MdiIcons.nintendoSwitch,
                size: 27,
                color: Colors.grey[900],
              )),
          fabMargin: EdgeInsets.only(bottom: 10),
          ringColor: victory == true ? Color(0xffdbc6eb) : Color(0xffffafb0),
          fabColor: victory == true ? Color(0xffb590ca) : Color(0xfff67280),
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.meeting_room_rounded, size: 30),
                onPressed: () {
                  if (head == 'host') {
                    game.deleteCollection();
                  }
                  Navigator.pushAndRemoveUntil(
                      context,
                      RevealRoute(
                        page: Avalon(),
                        maxRadius: 117.0.h,
                        centerAlignment: Alignment.bottomRight,
                      ),
                      ModalRoute.withName('/'));
                }),
            IconButton(
                icon: Icon(
                  Icons.sports_esports_rounded,
                  size: 30,
                ),
                onPressed: () async {
                  bool checkRoom = await game.checkRoom();
                  bool checkSettings = await game.checkSettings();
                  print('Checkroom ' + checkRoom.toString());
                  print('CheckSettings    ' + checkSettings.toString());
                  if (checkSettings) {
                    if (checkRoom == false) {
                      await game.updateGameSettings();
                      await game.updateUserData(username, '1');
                      int player_no = 1;
                      Navigator.pushAndRemoveUntil(
                          context,
                          RevealRoute(
                            page: Room(head, game, player_no),
                            maxRadius: 100.0.h * 1.17,
                            centerAlignment: Alignment.bottomCenter,
                          ),
                          ModalRoute.withName('/'));
                    } else {
                      int player_no;
                      bool checkLock = await game.checkLocked(game.game_key);
                      if (checkLock == false) {
                        for (int i = 1; i <= 10; i += 1) {
                          final playerCheck = await FirebaseFirestore.instance
                              .collection(game.game_key)
                              .doc(i.toString())
                              .get();

                          if (playerCheck.exists) {
                            continue;
                          } else {
                            player_no = i;
                            print(username);
                            await game.updateUserData(username, i.toString());
                            break;
                          }
                        }
                        Navigator.pushAndRemoveUntil(
                            context,
                            RevealRoute(
                              page: Room(head, game, player_no),
                              maxRadius: 100.0.h * 1.17,
                              centerAlignment: Alignment.bottomCenter,
                            ),
                            ModalRoute.withName('/'));
                      } else {
                        Navigator.pushAndRemoveUntil(
                            context,
                            RevealRoute(
                              page: Avalon(),
                              maxRadius: 100.0.h * 1.17,
                              centerAlignment: Alignment.bottomCenter,
                            ),
                            ModalRoute.withName('/'));
                      }
                    }
                  } else {
                    Navigator.pushAndRemoveUntil(
                        context,
                        RevealRoute(
                          page: Avalon(),
                          maxRadius: 100.0.h * 1.17,
                          centerAlignment: Alignment.bottomCenter,
                        ),
                        ModalRoute.withName('/'));
                  }
                }),
          ]),
    );
  }
}
