import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutwest/model/vars.dart';

class Utils {
  Utils._();
  static void hideSysNavBarColour() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        /*systemNavigationBarDividerColor: Color.fromARGB(1, 0, 1, 51),*/
        systemNavigationBarColor: Color.fromARGB(1, 0, 1, 51)));

    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [
      SystemUiOverlay.top,
    ]);
  }

  static void showSysNavBarColour() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white));

    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [
      SystemUiOverlay.top,
    ]);
  }

  static String getDateIntTwoSig(int val) {
    if (val < 10) {
      return "0$val";
    }

    return val.toString();
  }

  static String getDateTimeWDDMY(DateTime dateTime) {
    return "${Vars.days[dateTime.weekday]} ${dateTime.day} ${Vars.months[dateTime.month]} ${dateTime.year}";
  }

  static String getDateTimeWDDMYToday(DateTime dateTime) {
    return Vars.isSameDay(dateTime, DateTime.now())
        ? "Today"
        : getDateTimeWDDMY(dateTime);
  }

  static String formatDecimalMoneyUS(Decimal decimal) {
    return Vars.usFormatter.format(decimal.toDouble());
  }
}
