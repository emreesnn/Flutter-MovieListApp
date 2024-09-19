import 'package:flutter/material.dart';
import 'package:movie_it/services/database_services.dart';

class ListEdit extends StatefulWidget {
  final String movieId; // movieId'yi constructor içinde al
  ListEdit({required this.movieId}); // constructor oluştur
  @override
  _ListEditState createState() => _ListEditState();
}

class _ListEditState extends State<ListEdit> {
  TextEditingController _listNameController = TextEditingController();

  List<String> userLists = [];
  DatabaseServices db = DatabaseServices();
  List<bool> isMovieListed = [];

  @override
  void initState() {
    super.initState();
    getListsFromDb();
  }

  void getListsFromDb() async {
    try {
      var lists = await db.getLists();
      setState(() {
        userLists = lists;
        isMovieListed = List.generate(userLists.length, (index) => false);
      });
      await checkedList(); // setState'den sonra checkedList'i çağırın
    } catch (e) {
      print('getDataFromDatabase hatası: $e'); // Hata durumunu yazdır
    }
  }

  Future<void> checkedList() async {
    String movieId = widget.movieId;
    List<bool> tempList =
        []; // Geçici bir liste kullanarak isCheckedList'i güncelleyin
    for (var list in userLists) {
      bool containsMovie =
          await db.isListContainsMovie(listName: list, movieId: movieId);
      tempList.add(containsMovie);
    }
    setState(() {
      isMovieListed =
          tempList; // Güncellenmiş isCheckedList'i setState içinde atayın
    });
  }

  @override
  Widget build(BuildContext context) {
    String movieId = widget.movieId;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Film Listesine Ekle"),
      ),
      body: ListView.builder(
        itemCount: userLists.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            checkboxShape: const CircleBorder(),
            checkColor: Colors.white,
            activeColor: Colors.green,
            title: Text(userLists[index]),
            value: isMovieListed[index],
            onChanged: (value) {
              isMovieListed[index]
                  ? db.removeListedMovie(
                      movieId: movieId, listName: userLists[index])
                  : db.updateMovieList(
                      movieId: movieId, listName: userLists[index]);
              setState(() {
                isMovieListed[index] = value!;
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        child: Icon(
          Icons.add,
          size: 30,
        ),
        onPressed: () {
          _showAddMovieDialog(context);
        },
      ),
    );
  }

  Future<void> _showAddMovieDialog(BuildContext context) async {
    String? listName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Yeni Liste Oluştur"),
          content: TextField(
            controller: _listNameController, // Doğru denetleyiciyi kullanın
            decoration: InputDecoration(
              hintText: "Liste adını girin",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await db.setMovieList(listName: _listNameController.text);
                  setState(() {
                    userLists.add(_listNameController.text);
                    isMovieListed.add(false);
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                    ),
                  );
                }

                Navigator.pop(context, _listNameController.text);
              },
              child: Text("Oluştur"),
            ),
          ],
        );
      },
    );
  }
}
