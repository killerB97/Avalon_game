import 'package:avalonapp/player_list.dart';
import 'package:avalonapp/services/database.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:avalonapp/models/player.dart';
import 'package:avalonapp/screens/role_descrip.dart';
import 'package:interpolation/interpolation.dart';
import 'dart:async';
import 'package:styled_text/styled_text.dart';

class roleSelection extends StatefulWidget {
  List<String> characterList;
  int player_no;
  List<String> player_list;
  DatabaseService game;
  String head;

  roleSelection(this.characterList, this.player_no, this.player_list, this.game,
      this.head);

  @override
  _roleSelectionState createState() =>
      _roleSelectionState(characterList, player_no, player_list, game, head);
}

class _roleSelectionState extends State<roleSelection> {
  List<String> characterList;
  int player_no;
  List<String> player_list;
  DatabaseService game;
  String head;
  List<String> userList;

  _roleSelectionState(this.characterList, this.player_no, this.player_list,
      this.game, this.head);

  Map characterMapping = {};
  bool flipped = true;

  Map color = {
    'Percival': Color.fromRGBO(255, 142, 113, 1),
    'Mordred': Color.fromRGBO(195, 172, 217, 1),
    'Merlin': Color.fromRGBO(95, 192, 237, 1),
    'Morgana': Color.fromRGBO(236, 82, 75, 1),
    'Oberon': Color.fromRGBO(135, 141, 162, 1),
    'Minion': Color.fromRGBO(142, 159, 155, 1),
    'Loyal Knight': Color.fromRGBO(37, 37, 37, 1)
  };

  Map descText = {
    'Percival':
        'You are Percival.\n\nMorgana fogs your vision from identifying Merlin. Choose wisely between {0} {1}',
    'Mordred':
        'You are Mordred.\n\nHidden from the eyes of the Virtuous. You unleash evil with your minions {0} {1}. Identity of Oberon is hidden from you',
    'Merlin':
        'You are Merlin.\n\nYou are instrumental in driving the forces of evil out. You have identified {0} {1} to be the forces of evil. But their overlord Mordred is hidden from you',
    'Morgana':
        'You are Morgana.\n\nYou confuse Percival and bring glory to Mordred. You unleash evil with your minions {0} {1}. Identity of Oberon is hidden from you',
    'Oberon':
        'You are Oberon.\n\n You are the wild card that confuses the Virtuous and the Vicious',
    'Minion':
        'You are a Minion.\n\nUnleash evil with {0} {1}. Oberon is hidden from you',
    'Loyal Knight':
        'You are a Loyal Knight.\n\nFaithful to King Arthur in his quest to root out all evil'
  };

  Map<String, List<String>> charDependency = {
    'Percival': ['Merlin', 'Morgana'],
    'Mordred': ['Morgana', 'Minion'],
    'Merlin': ['Morgana', 'Minion', 'Oberon'],
    'Minion': ['Mordred', 'Morgana'],
    'Morgana': ['Mordred', 'Minion'],
    'Oberon': [],
    'Loyal Knight': []
  };

  String getImagePath(String character) {
    if (character == 'Loyal Knight') {
      return 'images/knight.jpg';
    }
    return 'images/' + character.toLowerCase() + '.jpg';
  }

  void createCharMap() {
    for (int i = 0; i < widget.characterList.length; i++) {
      if (characterMapping.containsKey(widget.characterList[i])) {
        characterMapping[widget.characterList[i]].add(widget.player_list[i]);
      } else {
        characterMapping[widget.characterList[i]] = [widget.player_list[i]];
      }
      print(characterMapping);
    }
  }

  String generateDescription(String desc, List<String> depend) {
    if (depend.length > 0) {
      Map<String, dynamic> format = {'0': '', '1': ''};
      var inter = Interpolation();
      if (depend.length == 1) {
        depend =
            depend.map((x) => x[0].toUpperCase() + x.substring(1)).toList();
        format['0'] = depend.last;
        format['1'] = '';
      } else {
        depend =
            depend.map((x) => x[0].toUpperCase() + x.substring(1)).toList();
        format['0'] = depend.sublist(0, depend.length - 1).join(', ');
        format['1'] = 'and ' + depend.last;
      }
      print(format);
      String newDesc = inter.eval(desc, format);
      return newDesc;
    } else {
      return desc;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Container(
            child: Stack(children: [
      Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    colorFilter: new ColorFilter.mode(
                        Colors.white.withOpacity(0.8), BlendMode.lighten),
                    image: AssetImage("images/game_bg.jpeg"),
                    fit: BoxFit.fitHeight)),
          )),
      Column(
        children: [
          Container(
              margin: EdgeInsets.only(left: 8.5.w, right: 8.5.w),
              height: 6.25.h,
              decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey[800],
                        blurRadius: 0,
                        offset: Offset(0.0, 0.0)),
                  ],
                  color: Colors.yellow[300],
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50.0),
                      bottomRight: Radius.circular(50.0))),
              //color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 20.0.w),
                  Text(
                    'Select Character',
                    style: TextStyle(
                        fontSize: 18.2.sp,
                        fontFamily: 'hash',
                        color: Colors.grey[800],
                        decoration: TextDecoration.none),
                  ),
                ],
              )),
          SizedBox(
            height: 2.88.h,
          ),
          Expanded(
            child: Container(
                child: GridView.count(
              physics: BouncingScrollPhysics(),
              childAspectRatio: 3.0.sp / 4.0.sp,
              crossAxisCount: 2,
              crossAxisSpacing: 9.73.w,
              mainAxisSpacing: 2.3.h,
              padding: EdgeInsets.only(
                  top: 1.16.h, bottom: 3.46.h, left: 15.81.w, right: 15.81.w),
              children: widget.characterList
                  .asMap()
                  .entries
                  .map((item) => FlipCard(
                        flipOnTouch: flipped,
                        direction: FlipDirection.HORIZONTAL,
                        onFlip: () async {
                          setState(() {
                            flipped = false;
                          });
                          createCharMap();
                          userList = await game.getUserNames(player_list);
                          List<String> dependecyList = await widget.game
                              .getDependentChar(
                                  charDependency[widget.characterList[widget
                                      .player_list
                                      .indexOf(widget.player_no.toString())]],
                                  characterMapping,
                                  userList,
                                  player_list);
                          String description = generateDescription(
                              descText[widget.characterList[widget.player_list
                                  .indexOf(widget.player_no.toString())]],
                              dependecyList);

                          Timer(Duration(seconds: 1), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => roleDescription(
                                      getImagePath(widget.characterList[
                                          widget.player_list.indexOf(
                                              widget.player_no.toString())]),
                                      color[widget.characterList[
                                          widget.player_list.indexOf(
                                              widget.player_no.toString())]],
                                      item.key.toString(),
                                      widget.characterList[widget.player_list
                                          .indexOf(
                                              widget.player_no.toString())],
                                      description,
                                      head,
                                      player_list,
                                      userList,
                                      characterList,
                                      player_no.toString(),
                                      game)),
                            );
                          });
                        },
                        front: Container(
                            child: Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
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
                                      image: AssetImage('images/trial2.jpg'),
                                      fit: BoxFit.cover,
                                      alignment: Alignment.topCenter))),
                        )),
                        back: Hero(
                          tag: getImagePath(widget.characterList[widget
                                  .player_list
                                  .indexOf(widget.player_no.toString())]) +
                              item.key.toString(),
                          child: Container(
                              child: Card(
                            color: Colors.transparent,
                            elevation: 0,
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
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
                                        image: AssetImage(getImagePath(widget
                                                .characterList[
                                            widget.player_list.indexOf(
                                                widget.player_no.toString())])),
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter))),
                          )),
                        ),
                      ))
                  .toList(),
            )),
          ),
          Container(
            height: 3.46.h,
          )
        ],
      ),
    ])));
  }
}
