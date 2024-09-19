import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movie_it/firebase_options.dart';
import 'package:movie_it/view/discover_view.dart';
import 'package:movie_it/view/list_page_view.dart';
import 'package:movie_it/view/movie_detail_page.dart';
import 'package:movie_it/view/movie_page_view.dart';
import 'package:movie_it/view/profile_view.dart';
import 'package:movie_it/view/search_page_view.dart';
import 'package:movie_it/view/sign_in_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie It',   
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
       darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.dark, 
      
      routes: {
        
        "/":(context) => const MoviePageView(),
        "/detail":(context) => const movieDetailPage(),
        "/login":(context) => signIn(),
        "/search":(context) => searchPage(),
        "/profile":(context) => profile(),
        "/discover":(context) => discover(),
        "/list" :(context) => ListPage(),
      },
    );
  }
}

