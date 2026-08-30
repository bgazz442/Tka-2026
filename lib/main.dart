import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await StorageService.init();
  runApp(const TkaStudyApp());
}
