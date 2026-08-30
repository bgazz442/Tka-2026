import 'package:flutter/material.dart';
import '../models/subject.dart';

class SubjectsData {
  static const List<Subject> list = [
    Subject(
      id: 'english',
      title: 'Bahasa Inggris',
      description: 'Latihan TKA Bahasa Inggris',
      icon: '🇬🇧',
      primaryColor: Color(0xFF2563EB),
      backgroundColor: Color(0xFFEFF6FF),
      accentColor: Color(0xFF3B82F6),
    ),
    Subject(
      id: 'mathematics',
      title: 'Matematika',
      description: 'Latihan TKA Matematika',
      icon: '📐',
      primaryColor: Color(0xFF7C3AED),
      backgroundColor: Color(0xFFF5F3FF),
      accentColor: Color(0xFF8B5CF6),
    ),
    Subject(
      id: 'indonesian',
      title: 'Bahasa Indonesia',
      description: 'Latihan TKA Bahasa Indonesia',
      icon: '🇮🇩',
      primaryColor: Color(0xFF059669),
      backgroundColor: Color(0xFFECFDF5),
      accentColor: Color(0xFF10B981),
    ),
    Subject(
      id: 'entrepreneurship',
      title: 'Kewirausahaan',
      description: 'Latihan Kewirausahaan',
      icon: '💡',
      primaryColor: Color(0xFFD97706),
      backgroundColor: Color(0xFFFFFBEB),
      accentColor: Color(0xFFF59E0B),
    ),
  ];

  static Subject getById(String id) {
    return list.firstWhere(
      (s) => s.id == id,
      orElse: () => list.first,
    );
  }
}
