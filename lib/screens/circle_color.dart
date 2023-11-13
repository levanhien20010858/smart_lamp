// ignore_for_file: invalid_use_of_visible_for_testing_member, unnecessary_null_comparison

import 'dart:convert';
import "dart:math" as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_lamp/widgets/color_bloc.dart';
import 'package:smart_lamp/widgets/light_bloc.dart';
import 'package:smart_lamp/widgets/onoff_bloc.dart';
import 'package:smart_lamp/widgets/nd.dart';

import 'package:web_socket_channel/io.dart';

class Wheel {
  static double vectorToHue(Offset vector) =>
      (((math.atan2(vector.dy, vector.dx)) * 180.0 / math.pi) + 360.0) % 360.0;
  static double vectorToSaturation(double vectorX, double squareRadio) =>
      vectorX * 0.5 / squareRadio + 0.5;
  static double vectorToValue(double vectorY, double squareRadio) =>
      0.5 - vectorY * 0.5 / squareRadio;

  static Offset hueToVector(double h, double radio, Offset center) =>
      Offset(math.cos(h) * radio + center.dx, math.sin(h) * radio + center.dy);
  static double saturationToVector(
          double s, double squareRadio, double centerX) =>
      (s - 0.5) * squareRadio / 0.5 + centerX;
  static double valueToVector(double l, double squareRadio, double centerY) =>
      (0.5 - l) * squareRadio / 0.5 + centerY;
}

class WheelPicker extends StatefulWidget {
  final HSVColor color;
  final ValueChanged<HSVColor> onChanged;

  const WheelPicker({
    Key? key,
    required this.color,
    required this.onChanged,
  }) : super(key: key);

  @override
  _WheelPickerState createState() => _WheelPickerState();
}

class _WheelPickerState extends State<WheelPicker> {
  //'ws://10.20.215.102:8765'
  String ip = 'ws://192.168.137.57:8765';

  late IOWebSocketChannel channel;

  Map<String, dynamic> jsonData = {
    'leb': false,
    'color': '0xff2196f3',
    'bright': 100,
  };
  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(ip);
    jsonData['leb'] = context.read<ColorSmartBloc>().state;
  }

  HSVColor get color => widget.color;
  // Hàm để cập nhật giá trị light
  void updateLightValue(bool newLightValue) {
    setState(() {
      jsonData['leb'] = newLightValue;
    });
  }

  // Hàm để cập nhật giá trị color
  void updateColorValue(String newColorValue) {
    setState(() {
      jsonData['color'] = newColorValue;
    });
  }

  // // Hàm để cập nhật giá trị bright
  void updateBrightValue(double newColorValue) {
    setState(() {
      jsonData['bright'] = newColorValue;
    });
  }

  final GlobalKey paletteKey = GlobalKey();

  Offset getOffset(Offset ratio) {
    RenderBox renderBox =
        paletteKey.currentContext!.findRenderObject() as RenderBox;
    Offset startPosition = renderBox.localToGlobal(Offset.zero);
    return ratio - startPosition;
  }

  Size getSize() {
    RenderBox renderBox =
        paletteKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size;
  }

  bool showIndicator = false;

  bool isWheel = false;
  bool isPalette = false;

  void onPanStart(
    Offset offset,
    Size size,
  ) {
    showIndicator = true;
    onPanUpdate(offset, size, true);
  }

  void onPanUpdate(Offset offset, Size size, [bool start = false]) {
    double radio = _WheelPainter.radio(size);
    double squareRadio = _WheelPainter.squareRadio(radio);

    Offset startPosition = Offset.zero;
    Offset center = Offset(size.width / 2, size.height / 2);
    Offset vector = offset - startPosition - center;

    if (start) {
      bool isPalette =
          vector.dx.abs() < squareRadio && vector.dy.abs() < squareRadio;
      isWheel = !isPalette;
      this.isPalette = isPalette;
    }

    if (isWheel) {
      widget.onChanged(color.withHue(Wheel.vectorToHue(vector)));

      String colorsmart = color.toColor().value.toRadixString(16);
      print(color.toColor().value);
      updateColorValue(colorsmart);
      String jsonString = jsonEncode(jsonData);
      channel.sink.add(jsonString);
      // print("ddd");
    }
    if (isPalette) {
      widget.onChanged(
        HSVColor.fromAHSV(
          color.alpha,
          color.hue,
          Wheel.vectorToSaturation(vector.dx, squareRadio).clamp(0.0, 1.0),
          Wheel.vectorToValue(vector.dy, squareRadio).clamp(0.0, 1.0),
        ),
      );
    }
  }

  void onPanDown(Offset offset) => isWheel = isPalette = false;
  bool onoff = false;
  @override
  Widget build(BuildContext context) {
    ColorSmartBloc colorSmartBloc = BlocProvider.of<ColorSmartBloc>(context);
    OnoffSmartBloc onoffSmartBloc = BlocProvider.of<OnoffSmartBloc>(context);
    return Transform.scale(
      scale: 0.9,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: LayoutBuilder(builder: (context, consts) {
          final size = consts.biggest;

          return BlocBuilder<LightBloc, double>(builder: (context, brightness) {
            return GestureDetector(
              onPanStart: (details) => onPanStart(details.localPosition, size),
              onPanUpdate: (details) {
                setState(() {
                  if (channel.sink.done == null) {
                    channel = IOWebSocketChannel.connect(ip);
                  }
                });

                updateBrightValue(brightness);
                onPanUpdate(details.localPosition, size);
                colorSmartBloc.emit(color.toColor().value);
              },
              onPanDown: (details) => onPanDown(details.localPosition),
              onPanEnd: (details) => setState(() => showIndicator = false),
              child: Stack(
                key: paletteKey,
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _WheelPainter(color: color)),
                  ),
                  BlocBuilder<OnoffSmartBloc, bool>(builder: (context, status) {
                    return Positioned(
                      top: size.height / 2 - 160 / 2,
                      left: size.width / 2 - 160 / 2,
                      child: InkWell(
                        onTap: () {
                          final channel = IOWebSocketChannel.connect(ip);

                          // onoff = !onoff;
                          updateLightValue(!status);
                          onoffSmartBloc.emit(!status);

                          String jsonString = jsonEncode(jsonData);
                          channel.sink.add(jsonString);
                        },
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: status == false
                                ? Colors.black
                                : color.toColor(),
                            borderRadius: BorderRadius.circular(80),
                            border: Border.all(
                              color: Colors.white,
                              width: 5,
                            ),
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            color: Colors.white,
                            size: 70,
                          ),
                        ),
                      ),
                    );
                  })
                ],
              ),
            );
          });
        }),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  static double get strokeWidth => 8;
  static double get doubleStrokeWidth => 26;
  static double radio(Size size) =>
      math.min(size.width, size.height).toDouble() / 2 -
      _WheelPainter.strokeWidth;
  static double squareRadio(double radio) =>
      (radio - _WheelPainter.strokeWidth) / 1.414213562373095;

  final HSVColor color;

  _WheelPainter({required this.color}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radio = _WheelPainter.radio(size * 1.1);
    // double squareRadio = _WheelPainter.squareRadio(radio);

    // Wheel

    double wheelRadio = radio;

    Shader sweepShader = const SweepGradient(
      center: Alignment.bottomRight,
      colors: [
        Color.fromARGB(255, 255, 0, 0),
        Color.fromARGB(255, 255, 255, 0),
        Color.fromARGB(255, 0, 255, 0),
        Color.fromARGB(255, 0, 255, 255),
        Color.fromARGB(255, 0, 0, 255),
        Color.fromARGB(255, 255, 0, 255),
        Color.fromARGB(255, 255, 0, 0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, wheelRadio, wheelRadio));
    canvas.drawCircle(
      center,
      wheelRadio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _WheelPainter.doubleStrokeWidth
        ..shader = sweepShader,
    );
    canvas.drawCircle(
      center,
      100,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 50
        ..color = color.toColor(),
    );
    Offset wheel = Wheel.hueToVector(
      ((color.hue + 360.0) * math.pi / 180.0),
      wheelRadio,
      center,
    );
    // nút tròn
    canvas.drawCircle(
      wheel,
      wheelRadio * 0.15,
      Paint()
        ..color = Colors.black // Màu viền đen
        ..style =
            PaintingStyle.stroke // Sử dụng PaintingStyle.stroke để vẽ viền
        ..strokeWidth = 4.5, // Độ rộng của viền
    );

    canvas.drawCircle(
      wheel,
      wheelRadio * 0.15 - 3,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter other) => color != other.color;
}
