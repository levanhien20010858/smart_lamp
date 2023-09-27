import 'package:flutter/material.dart';
import '../size_config.dart';

class SliderLight extends StatefulWidget {
  const SliderLight({super.key});

  @override
  State<SliderLight> createState() => _SliderLightState();
}

class _SliderLightState extends State<SliderLight> {
  double _currentSliderValue = 20;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      width: SizeConfig.screenWidth! * 2 / 3,
      child: Slider(
        value: _currentSliderValue,
        activeColor: Colors.white,
        thumbColor: Colors.white,
        inactiveColor: Colors.grey,
        max: 100,
        divisions: 100,
        label: _currentSliderValue.round().toString(),
        onChanged: (double value) {
          setState(() {
            _currentSliderValue = value;
          });
        },
      ),
    );
  }
}
