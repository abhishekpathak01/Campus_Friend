import 'package:campus/home.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'home.dart';
import 'attendance.dart'; 
import 'exam.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Hive.initFlutter();

  
  Hive.registerAdapter(ExamAdapter());
  Hive.registerAdapter(SubjectAdapter());

 
  await Hive.openBox('subjectsBox');     
  await Hive.openBox<Exam>('examBox');    

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homepageee(),
    );
  }
}
