import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              gradient: RadialGradient(
            radius: 0.5,
            colors: [
              Color.fromARGB(255, 220, 30, 253),
              Color.fromARGB(255, 139, 43, 218)
            ],
          )),
        ),
        Positioned(
            top: MediaQuery.of(context).size.height * -0.3,
            left: MediaQuery.of(context).size.height * -0.2,
            child: RotationTransition(
                turns: const AlwaysStoppedAnimation(45.0 / 360.0),
                child: Column(
                  children: [
                    Container(
                        color: Color(0xFF000133),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.2),
                    Container(
                        color: Colors.red[900],
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.8),
                  ],
                ))),
        Positioned(
            bottom: MediaQuery.of(context).size.height * -0.7,
            left: MediaQuery.of(context).size.height * -0.1,
            child: RotationTransition(
              turns: AlwaysStoppedAnimation(-45 / 360),
              child: Container(
                  color: Colors.pink[400],
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height),
            ))
      ],
    );
  }
}
