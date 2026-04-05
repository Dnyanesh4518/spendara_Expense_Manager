import 'package:flutter/material.dart';

Route<T> slideUp<T>(Widget page) => PageRouteBuilder<T>(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: const Duration(milliseconds: 320),
  reverseTransitionDuration: const Duration(milliseconds: 280),
  transitionsBuilder: (_, animation, __, child) => SlideTransition(
    position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    ),
    child: child,
  ),
);
