import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env — локальный файл (в гит не попадает), держит адрес бэкенда.
  // Если его нет (чистый чекаут), просто остаёмся без него — ApiClient
  // сам угадает адрес по платформе.
  try {
    await dotenv.load();
  } catch (_) {}
  // Приложение поддерживает только вертикальную ориентацию.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const NurPayApp());
}
