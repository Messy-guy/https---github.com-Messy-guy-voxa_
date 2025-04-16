import 'package:flutter/material.dart';
import 'package:voice_assistant/Home_pa%20ge.dart';
import 'package:voice_assistant/pallete.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<void> main() async {
  await dotenv.load(); 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice-Assistant',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Pallete.scaffoldBackgroundColor,
        )
      ),
      home: const HomePage(),
    );
  }
}