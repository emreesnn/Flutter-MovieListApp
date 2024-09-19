import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_it/services/auth_service.dart';
import 'package:movie_it/services/database_services.dart';

import '../custom-widgets/bottomNavigationBar.dart';
import '../custom-widgets/chatBotWidget.dart';

class profile extends StatefulWidget {
  const profile({Key? key}) : super(key: key);

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String username = '';
  DatabaseServices dbs = DatabaseServices();
  List<List<dynamic>> userLikedMovies = [];
  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    AuthService().getUserName(uid: user!.uid).then((value) {
      setState(() {
        username = value;
      });
    });
    getLikedMovies();
  }

  void getLikedMovies() async {
    try {
      userLikedMovies = await dbs.getLikedMovies();
      
      setState(() {});
    } catch (e) {
      throw Exception("Beğenilen filmler getirilemedi : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150'), // Profil resmi buraya gelecek
                    ),
                    SizedBox(height: 16),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //profile-collection adlı fielda database'e kaydetmek gerekiyor. ondan sonra setState yaparak güncellenicek.
                profileCollection(context),
                profileCollection(context),
                profileCollection(context),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                AuthService().logout();
                Navigator.pushNamedAndRemoveUntil(
                    context, "/", (route) => false);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  "Çıkış Yap",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: chatBotWidget(),
      bottomNavigationBar: CustomBottomBar(),
    );
  }

  Card profileCollection(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Beğenilen Filmler',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                        ),
                        itemCount: userLikedMovies.length,
                        itemBuilder: (BuildContext context, int index) {
                          var movie = userLikedMovies[index];
                          return GestureDetector(
                            onTap: () {
                              // İlgili filmin detaylarına gitmek için buraya kod ekleyebilirsiniz
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16.0),
                                    ),
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w500${movie[0]['posterPath']}',
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    movie[0]['title'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Container(
          width: 100,
          height: 100,
          child: Icon(
            Icons.add,
            size: 40,
          ),
        ),
      ),
    );
  }
}
