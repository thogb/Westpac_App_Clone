import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutwest/cust_widget/west_logo.dart';
import 'package:flutwest/ui_page/cards_page.dart';
import 'package:flutwest/ui_page/guest_page.dart';
import 'package:flutwest/ui_page/home_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Color.fromARGB(1, 0, 1, 51),
      systemNavigationBarColor: Color.fromARGB(1, 0, 1, 51)));

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [
    SystemUiOverlay.top,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            appBarTheme: AppBarTheme(
                foregroundColor: Colors.black,
                iconTheme: IconThemeData(color: Colors.red[900]),
                backgroundColor: Colors.grey[50]),
            primarySwatch: Colors.blue,
            highlightColor: Colors.grey[200],
            splashFactory: NoSplash.splashFactory),
        //home: const HomePage(),
        home: const GuestPage());
    //home: const HomePage());
    /*
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: const WestLogo(
              width: 200.0,
            ),
          ),
        ));*/
  }
}
