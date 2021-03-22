import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

createNetworkDialog(BuildContext context) {
  return showDialog(
      barrierColor: Color(0xff1e1e1e).withOpacity(0.3),
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            backgroundColor: Color(0xff1e1e1e).withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Color(0xff1e1e1e).withOpacity(0.5),
                ),
                child: Icon(Icons.wifi_off_rounded,
                    color: Color(0xffffc68a), size: 32.0.w)));
      });
}
