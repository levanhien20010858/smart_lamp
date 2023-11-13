// ignore_for_file: invalid_use_of_visible_for_testing_member, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_lamp/app_style.dart';
import 'package:smart_lamp/screens/smart_light.dart';
import 'package:smart_lamp/widgets/color_bloc.dart';
import 'package:smart_lamp/widgets/light_bloc.dart';
import 'package:smart_lamp/widgets/nd.dart';
import 'package:smart_lamp/widgets/onoff_bloc.dart';
import 'package:web_socket_channel/io.dart';

import '../size_config.dart';

class DashBoard extends StatefulWidget {
  DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String ip = 'ws://192.168.137.57:8765';
  bool s1 = false;
  // LightModel light =
  //     LightModel(leb: false, bright: 50, colorLeb: "#0xff2196f3");

  Map<String, dynamic> data = {
    'temperature': 0.0,
    'humidity': 0.0,
  };
  double nhietdo = 15;
  List<String> images = [
    "assets/images/light-64.png",
    "assets/images/temperature-64.png",
    "assets/images/humidity-64.png",
  ];

  @override
  void initState() {
    super.initState();
  }

  List<String> texts = ["Smart Light", "Temperature", "Air Humidity"];
  @override
  Widget build(BuildContext context) {
    // appProvider.addLight(light);
    OnoffSmartBloc onoffSmartBloc = BlocProvider.of<OnoffSmartBloc>(context);
    NDSmartBloc ndSmartBloc = BlocProvider.of<NDSmartBloc>(context);

    SizeConfig().init(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 45),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon trên cùng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: const Icon(
                        Icons.apps,
                        size: 45,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: const Icon(
                        Icons.person,
                        size: 45,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    "Smart Devices ",
                    style: GoogleFonts.ubuntu(
                      textStyle: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 ô một hàng
                crossAxisSpacing:
                    10.0, // Khoảng cách giữa các phần tử trên cùng một dòng
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.9,
              ),
              itemCount: 3, // Tổng số ô
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                    color: colorDevices, // Màu nền của Container
                    borderRadius: BorderRadius.circular(10.0), // Độ bo tròn góc
                  ),
                  width: 200,
                  child: InkWell(
                    onTap: () {
                      print("1");
                      if (index == 0) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SmartLight()));
                      }
                    },
                    child: Stack(
                      children: [
                        Positioned(
                          // top: 30, // Vị trí top (y-axis) của widget này
                          // left: 40, // Vị trí left (x-axis) của widget này
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                Image.asset("${images[index]}"),
                                const SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  "${texts[index]}",
                                  style: GoogleFonts.ubuntu(
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                // đèn

                                if (index == 0)
                                  BlocBuilder<LightBloc, double>(
                                    builder: (context, brightness) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  (brightness.toInt())
                                                          .toString() +
                                                      "%",
                                                  style: GoogleFonts.ubuntu(
                                                    textStyle: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // if (s1 == true)
                                              BlocBuilder<OnoffSmartBloc, bool>(
                                                  builder: (context, snapshot) {
                                                return snapshot == true
                                                    ? BlocBuilder<
                                                        ColorSmartBloc, int>(
                                                        builder: (context,
                                                            colorsmart) {
                                                          // Sử dụng giá trị colorsmart để cập nhật giao diện của WheelPicker
                                                          return Container(
                                                            width: 25,
                                                            height: 25,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Color(
                                                                  colorsmart),
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Container();
                                              })
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                // nhiệt độ
                                if (index == 1)
                                  BlocBuilder<NDSmartBloc,
                                          Map<String, dynamic>>(
                                      builder: (context, ndbloc) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                ndbloc['temperature']
                                                        .toString() +
                                                    "°C",
                                                style: GoogleFonts.ubuntu(
                                                  textStyle: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (nhietdo >= 30)
                                              const Icon(
                                                Icons.sunny,
                                                color: Colors.red,
                                                size: 25,
                                              ),
                                            if (nhietdo <= 10)
                                              const Icon(
                                                Icons.severe_cold_sharp,
                                                color: Colors.blue,
                                                size: 25,
                                              ),
                                            if (nhietdo > 10 && nhietdo < 30)
                                              const Icon(
                                                Icons.energy_savings_leaf,
                                                color: Colors.green,
                                                size: 25,
                                              )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                // độ ẩm
                                if (index == 2)
                                  BlocBuilder<NDSmartBloc,
                                          Map<String, dynamic>>(
                                      builder: (context, ndbloc) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                ndbloc['humidity'].toString() +
                                                    "%",
                                                style: GoogleFonts.ubuntu(
                                                  textStyle: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 25,
                                              height: 25,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: colorDevices,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                              ],
                            ),
                          ),
                        ),
                        if (index == 0)
                          BlocBuilder<LightBloc, double>(
                              builder: (context, brightness) {
                            return BlocBuilder<ColorSmartBloc, int>(
                                builder: (context, colorbloc) {
                              return BlocBuilder<OnoffSmartBloc, bool>(
                                  builder: (context, onoffbloc) {
                                Map<String, dynamic> jsonData = {
                                  'leb': onoffbloc,
                                  'color': colorbloc,
                                  'bright': brightness,
                                };
                                return Positioned(
                                  top: 0, // Vị trí top (y-axis) của widget này
                                  right:
                                      0, // Vị trí left (x-axis) của widget này
                                  child: Switch.adaptive(
                                    activeColor: Colors.white,
                                    activeTrackColor: colorButton,
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.grey.shade400,
                                    splashRadius: 50.0,
                                    value: onoffbloc,
                                    onChanged: (value) {
                                      final channel =
                                          IOWebSocketChannel.connect(ip);
                                      String colorsmart1 =
                                          colorbloc.toRadixString(16);
                                      onoffSmartBloc.emit(value);
                                      setState(() {
                                        s1 = value;
                                        jsonData['color'] = colorsmart1;
                                        jsonData['leb'] = value;
                                        String jsonString =
                                            jsonEncode(jsonData);
                                        channel.sink.add(jsonString);
                                        // print(jsonData);
                                        channel.stream.listen((message) {
                                          var data1 = json.decode(message);
                                          ndSmartBloc.emit(data1);
                                          print(data1.runtimeType);
                                        });
                                      });
                                    },
                                  ),
                                );
                              });
                            });
                          }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // void dispose() {
  //   channel.sink.close();
  //   super.dispose();
  // }
}
