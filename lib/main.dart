import 'package:flutter/material.dart';
import 'package:snapp_sample/constants/dimens.dart';
import 'package:snapp_sample/screens/map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snapp Sample',
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return const Color.fromARGB(255, 0, 238, 40);
              }
              return const Color.fromARGB(255, 2, 207, 36);
            }),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimens.medium),
              ),
            ),
            foregroundColor: const MaterialStatePropertyAll(Colors.white),
            fixedSize:
                const MaterialStatePropertyAll(Size(double.infinity, 50)),
            elevation: const MaterialStatePropertyAll(0),
            overlayColor:
                const MaterialStatePropertyAll(Color.fromARGB(255, 0, 238, 40)),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(1000)),
          backgroundColor: Colors.white,
        ),
      ),
      home: const MapScreen(),
    );
  }
}
