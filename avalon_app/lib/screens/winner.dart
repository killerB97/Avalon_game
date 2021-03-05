import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/services.dart';
import 'package:avalonapp/circleReveal.dart';
import 'package:sizer/sizer.dart';
import 'package:avalonapp/main.dart';

class SecondScreen extends StatelessWidget {
  bool victory;
  SecondScreen({this.victory});
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
                        ));
                  }),
            );
          },
        ));
  }
}

class Winner extends StatelessWidget {
  bool victory;

  Winner({this.victory});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
      )),
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
                  Navigator.push(
                    context,
                    RevealRoute(
                      page: Avalon(),
                      maxRadius: 117.0.h,
                      centerAlignment: Alignment.bottomRight,
                    ),
                  );
                }),
            IconButton(
                icon: Icon(
                  Icons.sports_esports_rounded,
                  size: 30,
                ),
                onPressed: () {}),
          ]),
    );
  }
}
