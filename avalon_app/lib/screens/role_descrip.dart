import 'package:avalonapp/screens/role_select.dart';
import 'package:avalonapp/screens/round_table.dart';
import 'package:avalonapp/services/database.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:avalonapp/circleReveal.dart';
import 'round_table.dart';

class roleDescription extends StatelessWidget {
  String assetPath;
  var color;
  String index;
  String roleName;
  String description;
  String head;
  DatabaseService game;
  List<String> player_list;
  String player_no;
  List<String> users;
  List<String> roleList;

  roleDescription(
      this.assetPath,
      this.color,
      this.index,
      this.roleName,
      this.description,
      this.head,
      this.player_list,
      this.users,
      this.roleList,
      this.player_no,
      this.game);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {},
      child: SafeArea(
        child: Container(
            child: Stack(
          overflow: Overflow.visible,
          children: [
            Container(
              height: size.height,
              width: size.width,
              color: color,
              child: Padding(
                padding: EdgeInsets.only(top: 13.51.h),
                child: Text(
                  roleName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'goldsmith',
                      fontSize: 9.24.h,
                      decoration: TextDecoration.none),
                ),
              ),
            ),
            Positioned(
              top: 35.8.h,
              child: Container(
                height: 65.0.h,
                width: 100.0.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0.w),
                        topRight: Radius.circular(0.0))),
                child: Padding(
                  padding:
                      EdgeInsets.only(right: 5.0.w, left: 8.51.w, top: 12.0.h),
                  child: Text(
                    description,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontFamily: 'am',
                        fontSize: 25.0.sp,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 26.56.h,
              right: 7.3.w,
              child: Hero(
                  tag: assetPath + index,
                  child: Container(
                      height: 110.0.sp,
                      width: 80.0.sp,
                      child: Card(
                        color: Colors.transparent,
                        elevation: 0,
                        child: Container(
                            decoration: BoxDecoration(
                                boxShadow: [
                              BoxShadow(
                                color: Colors.grey[400],
                                blurRadius: 0.0,
                                spreadRadius: -1.0,
                                offset: Offset(
                                    0.0, 6.0), // shadow direction: bottom right
                              )
                            ],
                                borderRadius: BorderRadius.circular(7.3.w),
                                image: DecorationImage(
                                    image: AssetImage(assetPath),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter))),
                      ))),
            ),
            Positioned.fill(
              top: 87.5.h,
              bottom: 0,
              left: 0,
              right: 0,
              child: FlatButton(
                padding: EdgeInsets.only(
                    left: 2.43.w, right: 2.43.w, top: 1.73.h, bottom: 1.16.h),
                color: color,
                onPressed: () async {
                  Navigator.push(
                    context,
                    RevealRoute(
                      page: roundTable(player_list, 'host', users, player_no,
                          game, roleName, roleList),
                      maxRadius: size.height * 1.17,
                      centerAlignment: Alignment.bottomRight,
                    ),
                  );
                },
                child: Text('Enter Round Table',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.2.sp,
                        fontFamily: 'calv',
                        fontWeight: FontWeight.normal)),
              ),
            )
          ],
        )),
      ),
    );
  }
}
