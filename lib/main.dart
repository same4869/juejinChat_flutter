import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:juejin_chat_demo/data/database.dart';
import 'package:juejin_chat_demo/router.dart';
import 'package:juejin_chat_demo/widgets/chat_screen.dart';

import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  db = await $FloorAppDatabase.databaseBuilder('app_database.db').addMigrations(
    [
      Migration(1, 2, (database) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Session` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL)');
        await database
            .execute('ALTER TABLE Message ADD COLUMN session_id INTEGER');
        await database
            .execute("insert into Session (id, title) values (1, 'Default')");
        await database.execute("UPDATE Message SET session_id = 1 WHERE 1=1");
      })
    ],
  ).build();
  runApp(
      //为了能让组件读取provider,我们需要将整个应用都包裹下
      const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      routerConfig: router,
    );
  }
}
