import 'package:flutter/material.dart';
import 'package:movie_it/services/database_services.dart';
import 'package:movie_it/services/get_data.dart';

class ListIndex extends StatefulWidget {
  //Get listname from other page and defining it for class scope
  final String listName;
  const ListIndex({super.key, required this.listName});

  @override
  State<ListIndex> createState() => _ListIndexState();
}

class _ListIndexState extends State<ListIndex> {
  var dbs = DatabaseServices();
  var getMovieData = getDataFromApi();
  late List<dynamic> movieDatas = [];
  late String posterPath;
  var posterUrl = "https://image.tmdb.org/t/p/w500/";

  @override
  void initState() {
    super.initState();
    getListedMovies(listname: widget.listName);
  }

  void getListedMovies({required String listname}) async {
    try {
      var listedMovies = await dbs.getMovieByList(listName: listname);
      for (var movie in listedMovies) {
        var movieData = await getMovieData.fetchMovie(movieId: movie);
        movieDatas.add(movieData);
      }
      //setstate to update movieDatas
      setState(() {});
    } catch (e) {
      throw new Exception("Listelenmiş filmler getirilemedi : " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.listName)),
      body: ListView.builder(
        itemCount: movieDatas.length,
        itemBuilder: (context, index) {
          final movie = movieDatas[index][0];
          var title = movie['title'] ?? 'Hata';
          var overview = movie['overview'] ?? 'Hata';
          var publishDate = movie['release_date'] ?? DateTime(0);
          publishDate = DateTime.parse(publishDate);
          posterPath = movie['posterPath'];
          var movieId = movie['id'].toString();
          var time = movie['runtime'];
          return listedItem(title, overview, publishDate, time, movieId, index);
        },
      ),
    );
  }

  Widget listedItem(
      title, overview, publishDate, time, String movieId, int index) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, "/detail", arguments: {
          "movieId": movieDatas[index][0]['id'].toString(),
        });
      },
      child: Card(
        child: SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    posterUrl + posterPath,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 2.0, 2.0, 2.0),
                  child: _MovieDesc(
                    title: title,
                    subtitle: overview,
                    publishDate: publishDate.year.toString(),
                    duration: (time.toString() + " dakika"),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                ),
                onPressed: () {
                  try {
                    dbs.removeListedMovie(movieId: movieId, listName: widget.listName);
                    setState(() {
                      movieDatas.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Film listeden kaldırıldı.')),
                    );
                  } catch (e) {
                    throw Exception(e);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovieDesc extends StatelessWidget {
  const _MovieDesc({
    required this.title,
    required this.subtitle,
    required this.publishDate,
    required this.duration,
  });

  final String title;
  final String subtitle;
  final String publishDate;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 2.0)),
        Expanded(
          child: Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.0,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          '$publishDate - $duration',
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
