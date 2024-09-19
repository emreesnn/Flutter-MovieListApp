import 'package:flutter/material.dart';
import 'package:movie_it/services/database_services.dart';
import 'package:movie_it/view/list_index_view.dart';
import '../custom-widgets/bottomNavigationBar.dart';
import '../custom-widgets/chatBotWidget.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late DatabaseServices dbs;
  late List<List<dynamic>> likedMovies = [];
  late List<String> userLists = [];
  late String posterPath;
  var posterUrl = "https://image.tmdb.org/t/p/w500/";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    dbs = DatabaseServices();
    getDataFromDatabase();
  }

  void getDataFromDatabase() async {
    try {
      var movies = await dbs.getLikedMovies();
      var lists = await dbs.getLists();
      setState(() {
        likedMovies = movies;
        userLists = lists;
      });
    } catch (e) {
      print('getDataFromDatabase hatası: $e'); // Hata durumunu yazdır
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.thumb_up),
              text: "Beğendiklerim",
            ),
            Tab(
              icon: Icon(Icons.watch_later_outlined),
              text: "Listelerim",
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            ListView.builder(
              itemCount: likedMovies.length,
              itemBuilder: (context, index) {
                final movie = likedMovies[index][0];
                var title = movie['title'] ?? 'Hata';
                var overview = movie['overview'] ?? 'Hata';
                var publishDate = movie['release_date'] ?? 'Hata';
                publishDate = DateTime.parse(publishDate);
                posterPath = movie['posterPath'];
                var movieId = movie['id'].toString();
                var time = movie['runtime'];
                return likedItem(
                    title, overview, publishDate, time, movieId, index);
              },
            ),
            ListView.builder(
              itemCount: userLists.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ListIndex(listName: userLists[index].toString()),
                        ),
                      );
                    },
                    leading: Icon(Icons.list),
                    title: Text(userLists[index]),
                    trailing: IconButton(
                        onPressed: () {
                          try {
                            dbs.deleteList(listName: userLists[index]);
                            setState(() {
                              userLists.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Liste silindi.')),
                            );
                          } catch (e) {
                            throw Exception(e);
                          }
                        },
                        icon: Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                        )),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: chatBotWidget(),
      bottomNavigationBar: CustomBottomBar(),
    );
  }

  Widget likedItem(
      title, overview, publishDate, time, String movieId, int index) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, "/detail", arguments: {
          "movieId": likedMovies[index][0]['id'].toString(),
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
                  Icons.thumb_up,
                  color: Colors.blue,
                ),
                onPressed: () {
                  try {
                    dbs.removeMovieLike(movieId: movieId);
                    setState(() {
                      likedMovies.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Beğenilenlerden kaldırıldı')),
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

class CustomListItem extends StatelessWidget {
  const CustomListItem({
    Key? key,
    required this.poster,
    required this.title,
    required this.subtitle,
    required this.publishDate,
    required this.duration,
    required this.movieId,
    required this.index,
    required this.dbs,
  }) : super(key: key);

  final Widget poster;
  final String title;
  final String subtitle;
  final String publishDate;
  final String duration;
  final String movieId;
  final DatabaseServices dbs;
  final int index;

  @override
  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.0,
              child: poster,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 2.0, 2.0, 2.0),
                child: _MovieDesc(
                  title: title,
                  subtitle: subtitle,
                  publishDate: publishDate,
                  duration: duration,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.thumb_up,
                color: Colors.blue,
              ), // Örnek bir ikon ekledim
              onPressed: () {
                try {
                  dbs.removeMovieLike(movieId: movieId);

                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text('Beğenilenlerden kaldırıldı')),
                  // );
                } catch (e) {
                  throw Exception(e);
                }
              },
            ),
          ],
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
