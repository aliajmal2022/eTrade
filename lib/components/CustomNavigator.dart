import 'package:flutter/material.dart';

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({required this.builder, required this.slide})
      : super(builder: builder);
  WidgetBuilder builder;
  String slide;
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // if (settings.isInitialRoute) return child;
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return SlideTransition(
        position: slide == "Left"
            ? Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                .animate(animation)
            : Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
                .animate(animation),
        child: FadeTransition(opacity: animation, child: child));
  }
}
