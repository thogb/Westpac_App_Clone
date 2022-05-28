import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutwest/controller/firestore_controller.dart';
import 'package:flutwest/controller/sqlite_controller.dart';
import 'package:flutwest/model/utils.dart';
import 'package:flutwest/model/vars.dart';
import 'package:flutwest/ui_page/guest_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Utils.hideSysNavBarColour();

  await SQLiteController.instance.loadDB();

  // WidgetsFlutterBinding.ensureInitialized();
  FirestoreController.instance.setFirebaseFireStore(FakeFirebaseFirestore());
  //FirestoreController.instance.enablePersistentData(true);
  Utils.putData();

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
            androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
            scaffoldBackgroundColor: Colors.grey[50],
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    primary: Vars.clickAbleColor,
                    textStyle: const TextStyle(
                        fontSize: Vars.headingTextSize2,
                        fontWeight: FontWeight.w400))),
            appBarTheme: AppBarTheme(
                //color: Colors.grey[50],
                actionsIconTheme:
                    const IconThemeData(color: Vars.clickAbleColor),
                titleTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: Vars.headingTextSize1,
                    fontWeight: Vars.medBold),
                foregroundColor: Colors.black,
                iconTheme:
                    const IconThemeData(color: Vars.clickAbleColor, size: 25),
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
