import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:movie_it/services/database_services.dart';
import 'package:movie_it/services/auth_service.dart';
import 'package:movie_it/services/get_data.dart';

import 'list_edit_page_viev.dart';

class movieDetailPage extends StatefulWidget {
  const movieDetailPage({super.key});

  @override
  State<movieDetailPage> createState() => _movieDetailPageState();
}

class _movieDetailPageState extends State<movieDetailPage> {
  late getDataFromApi movieData;
  late String movieId;
  bool isMovieDetailLoaded = false;
  var db = DatabaseServices();
  var authS = AuthService();
  bool isMovieLiked = false;
  bool isMovieLaterListed = false;
  bool isMovieListed = false;
  @override
  void initState() {
    super.initState();
    movieData = getDataFromApi();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getMovieDetail();
  }

  Future<void> getMovieDetail() async {
    var data =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    movieId = data['movieId'].toString();
    movieData.getMovieDetail(movieId: movieId).then((_) {
      setState(() {
        isMovieDetailLoaded = true;
        likeCheck();
        watchLaterCheck();
      });
    }).catchError((error) {
      print('getMovieDetail Error: $error');

      setState(() {
        isMovieDetailLoaded = true;
      });
    });
  }

  Future<void> likeCheck() async {
    bool isMovieLikedCheck = await db.isMovieLiked(movieId: movieId);
    setState(() {
      isMovieLiked = isMovieLikedCheck;
    });
  }

  Future<void> watchLaterCheck() async {
    bool isMovieLateredCheck = await db.isMovieLaterListed(movieId: movieId);
    setState(() {
      isMovieLaterListed = isMovieLateredCheck;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isMovieDetailLoaded) {
      // Veri yüklenene kadar bir yükleniyor ekranı veya başka bir şey gösterilebilir
      return const Center(child: CircularProgressIndicator());
    }
    List<dynamic>? movieDetailData = movieData.movieDetail;
    var posterPath = movieDetailData[0]['posterPath'];
    var backdropPath = movieDetailData[0]['backdropPath'];
    var backdropUrl = "https://image.tmdb.org/t/p/w500/$backdropPath";
    var posterUrl = "https://image.tmdb.org/t/p/w500/$posterPath";
    var genresList = movieDetailData[0]['genres'];
    var releaseDate = movieDetailData[0]['release_date'];
    DateTime dateTime = DateTime.parse(releaseDate);
    int year = dateTime.year;
    var runtime = movieDetailData[0]['runtime'];
    int hours = runtime ~/ 60;
    int minutes = runtime % 60;
    String voteAverage =
        movieDetailData[0]['vote_average'].toString().substring(0, 3);
    String overview = movieDetailData[0]['overview'];
    const double iconSize = 33;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                ),
                Positioned(
                  top: 0,
                  bottom: 75,
                  width: 415,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.transparent
                          .withOpacity(0.2), // Opaklık değeri burada ayarlanır
                      BlendMode.srcATop,
                    ),
                    child: Image.network(
                      backdropUrl,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                    top: 25,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )),
                Positioned(
                    left: 15,
                    bottom: 0,
                    height: 150,
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        posterUrl,
                        fit: BoxFit.fill,
                      ),
                    )),
                Positioned(
                  left: 145,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 270,
                    height: 75,
                    //color: Colors.amber,
                    child: Text(
                      movieDetailData != null && movieDetailData.isNotEmpty
                          ? movieDetailData[0]['title']
                          : 'Hata',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark_add,
                      size: iconSize,
                    ),
                    onPressed: () {
                      if (authS.isUserAuthenticated()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListEdit(
                                movieId:
                                    movieId), // movieId'yi ListEdit sayfasına gönder
                          ),
                        );
                      } else {
                        _flushbarMessage(context,
                            text: "Lütfen Giriş Yapın", color: Colors.red);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      size: iconSize,
                      color: isMovieLiked ? Colors.red : Colors.grey[400],
                    ),
                    onPressed: () {
                      if (authS.isUserAuthenticated()) {
                        isMovieLiked
                            ? db.removeMovieLike(movieId: movieId)
                            : db.setMovieLike(movieId: movieId);
                        setState(() {
                          isMovieLiked = !isMovieLiked;
                        });
                      } else {
                        _flushbarMessage(context,
                            text: "Lütfen Giriş Yapın", color: Colors.red);
                      }
                    },
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.star_outline_rounded, size: iconSize),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.watch_later,
                      size: iconSize,
                      color: isMovieLaterListed ? Colors.blue : Colors.grey[400],
                    ),
                    onPressed: () {
                      if (authS.isUserAuthenticated()) {
                        isMovieLaterListed
                            ? db.removeListedMovie(listName: "watch-later",movieId: movieId)
                            : db.setWatchLater(movieId: movieId);
                        setState(() {
                          isMovieLaterListed = !isMovieLaterListed;
                        });
                      } else {
                        _flushbarMessage(context,
                            text: "Lütfen Giriş Yapın", color: Colors.red);
                      }
                    },
                  ),
                ],
              ),
            ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.black12,
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  greyLabelText(text: 'Skor'),
                                  greyLabelText(text: 'Süre'),
                                  greyLabelText(text: 'Yapım Yılı'),
                                  greyLabelText(text: 'Tür'),
                                ],
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(voteAverage),
                                  Text('$hours saat $minutes dakika'),
                                  Text("$year"),
                                  Row(
                                    children: [
                                      for (var i = 0;
                                          i < genresList.length;
                                          i++)
                                        Text(genresList[i]['name'].toString() +
                                            (i == genresList.length - 1
                                                ? ''
                                                : ", "))
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          greyLabelText(text: "Genel Bakış"),
                          SingleChildScrollView(
                            child: Text(
                              overview,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Text greyLabelText({required String text}) {
    return Text(
      text,
      style: TextStyle(color: Colors.grey),
    );
  }

  Flushbar<dynamic> _flushbarMessage(BuildContext context,
      {required String text, required Color color}) {
    return Flushbar(
      messageText: Center(
          child: Text(
        text,
        style: TextStyle(color: Colors.white),
      )),
      backgroundColor: color,
      flushbarPosition: FlushbarPosition.TOP,
      positionOffset: 30,
      maxWidth: 300,
      borderRadius: BorderRadius.circular(40),
      duration: Duration(seconds: 3),
    )..show(context);
  }
}
