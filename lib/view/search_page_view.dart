import 'package:flutter/material.dart';
import 'package:movie_it/services/get_data.dart';

class searchPage extends StatefulWidget {
  searchPage({super.key});

  @override
  State<searchPage> createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  final FocusNode _focusNode = FocusNode();
  late getDataFromApi api;
  void initState() {
    super.initState();
    api = getDataFromApi();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  TextEditingController _searchController = TextEditingController();
  late var searchValue;
  List<dynamic> searchedMovies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 35.0),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(width: 1), color: Colors.black26),
              child: Row(children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    )),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      searchValue = _searchController.text;
                      api.searchMovie(query: searchValue).then((movies) {
                        setState(() {
                          searchedMovies = movies;
                        });
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Ara...",
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: searchedMovies.isEmpty && _searchController.text != ''
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount:
                            searchedMovies.length, // Liste elemanı sayısı
                        itemBuilder: (
                          BuildContext context,
                          int index,
                        ) {
                          // Her bir eleman için çağrılacak widget
                          return InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, "/detail",
                                    arguments: {
                                      "movieId": searchedMovies[index]['id']
                                          .toString(),
                                    });
                              },
                              child:
                                  searchedMovies[index]['backdropPath'] != null
                                      ? movieViewModel(
                                          imagePath: searchedMovies[index]
                                              ['backdropPath'],
                                          title: searchedMovies[index]['title'],
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!)
                                      : movieViewModel(
                                          imagePath: "null",
                                          title: searchedMovies[index]['title'],
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!));
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Sayfa kapatıldığında TextEditingController nesnesini temizleme
    _searchController.dispose();
    super.dispose();
  }
}

Widget movieViewModel({
  required String imagePath,
  required String title,
  required TextStyle textStyle,
}) {
  var image = 'https://image.tmdb.org/t/p/w1280$imagePath';
  var noImageURL =
      "https://peoplevine.blob.core.windows.net/media/72/e86f3854-ebcf-4025-ae66-220b51f77ec2/image_not_available.png";
  return Container(
    height: 250,
    margin: EdgeInsets.only(bottom: 10.0),
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      image: DecorationImage(
        image: NetworkImage(image),
        fit: BoxFit.cover,
      ),
    ),
    child: Stack(
      children: [
        imagePath != "null"
            ? Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    noImageURL,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Text(
            title,
            style: textStyle.copyWith(
              color: Colors.grey[200],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
