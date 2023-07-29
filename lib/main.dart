import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study/providers/board_list_state.dart';
import 'package:study/providers/board_provider.dart';
import 'package:study/screen/main_board.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BoardListState()),
        ChangeNotifierProvider(create: (context) => BoradProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Board',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BoardPage(),
    );
  }
}
