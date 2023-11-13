import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lamp/screens/dashboard.dart';
import 'package:smart_lamp/widgets/color_bloc.dart';
import 'package:smart_lamp/widgets/light_bloc.dart';
import 'package:smart_lamp/widgets/nd.dart';
import 'package:smart_lamp/widgets/onoff_bloc.dart';
import 'utils.dart' as utils;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  utils.preferences = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LightBloc()),
        BlocProvider(create: (context) => ColorSmartBloc()),
        BlocProvider(create: (context) => OnoffSmartBloc()),
        BlocProvider(create: (context) => NDSmartBloc()),
      ],
      child: MaterialApp(
        home: DashBoard(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
