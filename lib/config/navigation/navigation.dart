import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Route<dynamic>? onGenerateRoute(RouteSettings settings) => null;

class Navigation {
  static BuildContext currentContext = navigatorKey.currentContext!;

  static Future<dynamic> push(Widget page) =>
      navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => page));

  static Future<dynamic> pushAndRemoveUntil(Widget page) =>
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => page),
        (_) => false,
      );

  static Future<dynamic> navigateAndPopUntilFirstPage(Widget page) =>
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => page),
        (route) => route.isFirst,
      );

  static Future<dynamic> pushReplacement(Widget page) => navigatorKey
      .currentState!
      .pushReplacement(MaterialPageRoute(builder: (_) => page));

  static void pop() => navigatorKey.currentState!.pop();
}
