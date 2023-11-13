// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_lamp/app_style.dart';
import 'package:smart_lamp/size_config.dart';
import 'package:smart_lamp/widgets/color_bloc.dart';
import 'package:smart_lamp/widgets/light_bloc.dart';
import 'package:smart_lamp/widgets/onoff_bloc.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:math' as math;
import '../../utils.dart';

import '../widgets/slider_light.dart';
import 'circle_color.dart';

class SmartLight extends StatefulWidget {
  SmartLight({super.key});

  @override
  State<SmartLight> createState() => _SmartLightState();
}

class _SmartLightState extends State<SmartLight> {
  bool s1 = false;
  String ip = 'ws://192.168.137.57:8765';
  final channel = IOWebSocketChannel.connect('ws://192.168.137.57:8765');
  double _currentSliderValue = 20;
  HSVColor color = HSVColor.fromColor(initialColor);

  @override
  Widget build(BuildContext context) {
    final lightBloc = BlocProvider.of<LightBloc>(context);

    return BlocBuilder<LightBloc, double>(builder: (context, brightness) {
      _currentSliderValue = brightness;
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
                      BlocBuilder<OnoffSmartBloc, bool>(
                          builder: (context, onoffbloc) {
                        return BlocBuilder<ColorSmartBloc, int>(
                            builder: (context, colorbloc) {
                          Map<String, dynamic> jsonData = {
                            'leb': onoffbloc,
                            'color': colorbloc,
                            'bright': brightness,
                          };
                          return SizedBox(
                            width: SizeConfig.screenWidth! * 2 / 3,
                            child: Slider(
                              value: brightness,
                              activeColor: Colors.white,
                              thumbColor: Colors.white,
                              inactiveColor: Colors.grey,
                              max: 100,
                              divisions: 100,
                              label: _currentSliderValue.round().toString(),
                              onChanged: (double value) {
                                String colorsmart1 =
                                    colorbloc.toRadixString(16);
                                lightBloc.emit(value);

                                setState(() {
                                  jsonData['color'] = colorsmart1;
                                  jsonData['bright'] = value;
                                  String jsonString = jsonEncode(jsonData);
                                  channel.sink.add(jsonString);
                                  print(jsonData);
                                });
                              },
                            ),
                          );
                        });
                      })
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
