import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_tech_task/presentation/pages/post_list_tab_page.dart';
import 'package:flutter_tech_task/presentation/pages/post_details_page.dart';
import 'package:flutter_tech_task/presentation/pages/comments_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      initialRoute: 'tabs/',
      routes: {
        'tabs/': (context) => const PostListTabPage(),
        'details/': (context) => const PostDetailsPage(),
        'comments/': (context) => const CommentsPage(),
      },
    );
  }
}
