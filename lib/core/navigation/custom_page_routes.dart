import 'package:flutter/material.dart';

/// Niestandardowe route z animacją fade dla przejścia splash->dashboard
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: duration,

         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(
             opacity: animation,
             child: child,
           );
         },
       );
}

/// Route z animacją slide up dla efektu "wynurzania się"
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  SlideUpPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 600),
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           const begin = Offset(0.0, 1.0); // Zaczyna z dołu
           const end = Offset.zero;
           const curve = Curves.easeInOut;

           var tween = Tween(begin: begin, end: end).chain(
             CurveTween(curve: curve),
           );

           return SlideTransition(
             position: animation.drive(tween),
             child: FadeTransition(
               opacity: animation,
               child: child,
             ),
           );
         },
       );
}

/// Route z animacją scale dla efektu "powiększania"
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  ScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 500),
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return ScaleTransition(
             scale:
                 Tween<double>(
                   begin: 0.0,
                   end: 1.0,
                 ).animate(
                   CurvedAnimation(
                     parent: animation,
                     curve: Curves.elasticOut,
                   ),
                 ),
             child: child,
           );
         },
       );
}
