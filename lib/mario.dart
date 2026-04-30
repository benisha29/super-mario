import 'package:flutter/material.dart';

class MyMario extends StatelessWidget {
  const MyMario({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.asset('lib/images/stop.png'),
    );
  }
}