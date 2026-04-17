import 'package:flutter/material.dart';

/// 同时尊重系统「减少动画」与应用内开关。
bool shouldReduceMotion({
  required BuildContext context,
  required bool userReduceMotion,
}) {
  return MediaQuery.disableAnimationsOf(context) || userReduceMotion;
}
