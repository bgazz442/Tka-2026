import 'package:flutter/material.dart';

class Subject {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color primaryColor;
  final Color backgroundColor;
  final Color accentColor;

  const Subject({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.backgroundColor,
    required this.accentColor,
  });
}
