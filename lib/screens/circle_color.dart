import 'dart:convert';
import 'dart:io';
import "dart:math" as math;
import 'dart:async';
import 'package:flutter/material.dart';

import '../../widgets/indicator.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final channel = IOWebSocketChannel.connect('ws://192.168.2.21:8765');
  Map<String, dynamic> jsonData = {
    'leb': false,
    'color': '#0xff2196f3',
  };
  HSVColor get color => widget.color;
  // Hàm để cập nhật giá trị light
  void updateLightValue(int newLightValue) {
    setState(() {
      jsonData['light'] = newLightValue;
    });
  }

  // Hàm để cập nhật giá trị color
  void updateColorValue(String newColorValue) {
    setState(() {
      jsonData['color'] = newColorValue;
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
      String colorsmart = "#0x" + color.toColor().value.toRadixString(16);
      // channel.sink.add(colorsmart);
      updateColorValue(colorsmart);
      String jsonString = jsonEncode(jsonData);
      channel.sink.add(jsonString);
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
  int onoff = 0;
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.9,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: LayoutBuilder(builder: (context, consts) {
          final size = consts.biggest;
          final center = Offset(size.width / 2, size.height / 2);
          final squareRadio =
              _WheelPainter.squareRadio(_WheelPainter.radio(size * 1.1));
          final indicatorX = Wheel.saturationToVector(
            color.saturation,
            squareRadio,
            center.dx,
          );
          final indicatorY = Wheel.valueToVector(
            color.value,
            squareRadio,
            center.dy,
          );
          return GestureDetector(
            onPanStart: (details) => onPanStart(details.localPosition, size),
            onPanUpdate: (details) => onPanUpdate(details.localPosition, size),
            onPanDown: (details) => onPanDown(details.localPosition),
            onPanEnd: (details) => setState(() => showIndicator = false),
            child: Stack(
              key: paletteKey,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _WheelPainter(color: color)),
                ),
                Positioned(
                  top: size.height / 2 - 160 / 2,
                  left: size.width / 2 - 160 / 2,
                  child: InkWell(
                    onTap: () {
                      if (onoff == 0) {
                        onoff = 1;
                      } else {
                        onoff = 0;
                      }
                      updateLightValue(onoff);
                      String jsonString = jsonEncode(jsonData);
                      channel.sink.add(jsonString);
                    },
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: onoff == 0 ? Colors.black : color.toColor(),
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
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
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
    double squareRadio = _WheelPainter.squareRadio(radio);

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
    Color colorchubiet = color.toColor();
    print("$colorchubiet");
  }

  @override
  bool shouldRepaint(covariant _WheelPainter other) => color != other.color;
}
