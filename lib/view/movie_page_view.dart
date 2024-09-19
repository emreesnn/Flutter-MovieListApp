import 'package:flutter/material.dart';
import 'package:movie_it/custom-widgets/bottomNavigationBar.dart';
import 'package:movie_it/custom-widgets/chatBotWidget.dart';
import 'package:movie_it/services/get_data.dart';
import 'package:shimmer/shimmer.dart';

class MoviePageView extends StatefulWidget {
  const MoviePageView({super.key});

  @override
  State<MoviePageView> createState() => _MoviePageViewState();
}

class _MoviePageViewState extends State<MoviePageView> {
  late getDataFromApi movieData;

  @override
  void initState() {
    super.initState();
    movieData = getDataFromApi();
    fetchData();
  }

  Future<void> fetchData() async {
    await movieData.getData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> popularMovies = movieData.popularMovies;
    List<dynamic> trendMovies = movieData.trendMovies;
    String _hintText = 'Ara...';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/search");
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  height: 50,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_outlined,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _hintText,
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Trend Filmler',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 254,
                child: trendMovies.isNotEmpty
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: trendMovies.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, "/detail", arguments: {
                                "movieId": trendMovies[index].id.toString(),
                              });
                            },
                            child: movieListItemHorizontal(
                              title: trendMovies[index].title,
                              posterPath: trendMovies[index].posterPath,
                              voteAverage: trendMovies[index].voteAverage,
                            ),
                          );
                        },
                      )
                    : Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (BuildContext context, int index) {
                            return HorizontalShimmerListItem();
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Popüler Filmler',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ),
              popularMovies.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: popularMovies.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, "/detail", arguments: {
                                "movieId": popularMovies[index].id.toString(),
                              });
                            },
                            child: movieListItemVertical(
                              title: popularMovies[index].title,
                              posterPath: popularMovies[index].posterPath,
                              voteAverage: popularMovies[index].voteAverage,
                              releaseDate: popularMovies[index].releaseDate,
                              genres: popularMovies[index].genresString,
                            ),
                          ),
                        );
                      },
                    )
                  : Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (BuildContext context, int index) {
                          return VerticalShimmerListItem();
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: chatBotWidget(),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}

Widget movieListItemHorizontal(
    {required String title,
    required String posterPath,
    required String voteAverage}) {
  var imageUrl = "https://image.tmdb.org/t/p/w185/$posterPath";
  return Container(
    margin: const EdgeInsets.only(right: 5),
    width: 140,
    height: double.infinity,
    child: Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned(
                bottom: 15,
                child: Container(
                    width: 140,
                    height: 195,
                    child: Image.network(imageUrl, fit: BoxFit.fill)),
              ),
              Positioned(
                  bottom: 0,
                  right: 5.0,
                  child: Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[800],
                      borderRadius: const BorderRadius.all(
                          Radius.circular(15)), // StadiumBorder'ın yarı çapı
                      border: Border.all(
                        color: Colors.white, // Kenarlık rengi
                        width: 2.0, // Kenarlık genişliği
                      ),
                    ),
                    child: Center(
                      child: Text(
                        voteAverage,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ))
            ],
          ),
        ),
        SizedBox(
          height: 25,
          width: double.infinity,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            maxLines: 1, // En fazla 2 satır
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget movieListItemVertical({
  required String title,
  required String posterPath,
  required String voteAverage,
  required String releaseDate,
  required List<String> genres,
}) {
  DateTime dateTime = DateTime.parse(releaseDate);
  String formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            'https://image.tmdb.org/t/p/original/$posterPath',
            width: 100,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                genres.join(', '),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    voteAverage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class VerticalShimmerListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HorizontalShimmerListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 199,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
    );
  }
}
