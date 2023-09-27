import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_lamp/app_style.dart';
import 'dart:math' as math;
import '../../utils.dart';

import '../widgets/slider_light.dart';
import 'circle_color.dart';

class SmartLight extends StatefulWidget {
  final Function(String, bool) callback;
  SmartLight({required this.callback});

  @override
  State<SmartLight> createState() => _SmartLightState();
}

class _SmartLightState extends State<SmartLight> {
  bool s1 = false;
  int volume = 0;
  HSVColor color = HSVColor.fromColor(initialColor);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 49, 14, 81),
      appBar: AppBar(
        title: Text(
          "Smart Light",
          style: GoogleFonts.ubuntu(
            textStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color.fromARGB(255, 49, 14, 81),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 25, right: 25, top: 40),
        children: [
          Column(
            children: [
              SizedBox(
                height: 340.0,
                width: MediaQuery.of(context).size.width,
                child: WheelPicker(
                  color: color,
                  onChanged: (color) => setState(() => this.color = color),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Bright",
                      style: GoogleFonts.ubuntu(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SliderLight(),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
