import 'package:flutter/material.dart';
import 'package:movie_it/services/get_data.dart';

import '../custom-widgets/bottomNavigationBar.dart';
import '../custom-widgets/chatBotWidget.dart';

class discover extends StatefulWidget {
  @override
  _discoverState createState() => _discoverState();
}

class _discoverState extends State<discover> {
  getDataFromApi getData = getDataFromApi();
  Map<String, List<dynamic>> moviesByGenres = {};
  List<dynamic> genres = [];
  @override
  void initState() {
    super.initState();
    getGenreList();
    getMoviesByGenres();
  }

  void getMoviesByGenres() async {
    try {
      moviesByGenres = await getData.getMoviesByGenres();
      print(moviesByGenres['Aksiyon']);
      print(moviesByGenres['Macera']);
      setState(() {});
    } catch (e) {
      throw Exception("Genrelerine göre Filmler getirilemedi: $e");
    }
  }

  void getGenreList() async {
    try {
      genres = await getData.getGenreList();
      setState(() {});
    } catch (e) {
      throw Exception("Genrelist getirilemedi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: ListView.builder(
        itemCount: moviesByGenres.length,
        itemBuilder: (context, index) {
          final category = moviesByGenres.keys.elementAt(index);
          final movies = moviesByGenres[category] ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  category,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return _buildMovieCard(movie);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: chatBotWidget(),
      bottomNavigationBar: CustomBottomBar(),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie) {
    var posterPath = movie['posterPath'];
    var imageUrl = "https://image.tmdb.org/t/p/w1280/$posterPath";
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      width: 160,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, "/detail", arguments: {
            "movieId": movie['id'].toString(),
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                movie['title'],
                style: TextStyle(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
