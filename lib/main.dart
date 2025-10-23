import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/lists_provider.dart';
import 'screens/lists_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ListsProvider()..loadLists(),
      child: MaterialApp(
        title: 'List Book',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const ListsScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
