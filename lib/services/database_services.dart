import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'get_data.dart';

class DatabaseServices {
  final userCollection = FirebaseFirestore.instance.collection("users");
  final listCollection = FirebaseFirestore.instance.collection("list");
  final firebaseAuth = FirebaseAuth.instance;
  final getDataFromApiS = getDataFromApi();
  Future<void> setMovieLike({required String movieId}) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        await userCollection.doc(user.uid).update({
          "like": FieldValue.arrayUnion([movieId]),
        });
      } catch (error) {
        throw Exception('Bir hata oluştu: $error');
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  Future<void> removeMovieLike({required String movieId}) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        await userCollection.doc(user.uid).update({
          "like": FieldValue.arrayRemove([movieId]),
        });
      } catch (error) {
        throw Exception('Bir hata oluştu: $error');
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  Future<bool> isMovieLiked({required String movieId}) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        var userDoc = await userCollection.doc(user.uid).get();
        var likeList = userDoc.get('like') as List<dynamic>?;
        // Eğer likeList null değilse ve movieId likeList içinde bulunuyorsa true döndür
        if (likeList != null && likeList.contains(movieId)) {
          return true;
        } else {
          return false;
        }
      } catch (error) {
        throw Exception('Bir hata oluştu: $error');
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  Future<List<List<dynamic>>> getLikedMovies() async {
    User? user = firebaseAuth.currentUser;
    List<List<dynamic>> likedMoviesList = [];
    //user check
    if (user != null) {
      //get doc check
      try {
        var userDoc = await userCollection.doc(user.uid).get();
        var likeList = userDoc.get('like') as List<dynamic>?;
        //is get doc successful check
        if (likeList != null) {
          for (var likedMovieId in likeList) {
            //get data from api check
            try {
              var likedMovieDetail = await getDataFromApiS.fetchMovie(
                movieId: likedMovieId,
              );

              likedMoviesList.add(likedMovieDetail);
            } catch (e) {
              print('GetDataFromAPI hatası: $e'); // Hata durumunu yazdır
            }
          }
        }

        return likedMoviesList;
      } catch (error) {
        print('Firebase Doc hatası: $error'); // Hata durumunu yazdır
        throw Exception('Firebase Doc hatası: $error');
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  Future<void> updateMovieList(
      {required String movieId, required String listName}) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        try {
          await listCollection.doc(user.uid).update({
            listName: FieldValue.arrayUnion([movieId]),
          });
        } catch (error) {
          await listCollection.doc(user.uid).set({
            listName: FieldValue.arrayUnion([movieId]),
          });
        }
      } catch (e) {
        throw Exception(
            "Bir hata oluştu. Film listeye eklenemedi" + e.toString());
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  Future<bool> isMovieLaterListed({required String movieId}) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        var listDoc = await listCollection.doc(user.uid).get();
        var watchLaterList = listDoc.get('watch-later') as List<dynamic>?;
        // Eğer likeList null değilse ve movieId likeList içinde bulunuyorsa true döndür
        if (watchLaterList != null && watchLaterList.contains(movieId)) {
          return true;
        } else {
          return false;
        }
      } catch (error) {
        throw Exception('Bir hata oluştu: $error');
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  Future<List<String>> getLists() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        var listDoc = await listCollection.doc(user.uid).get();
        Map<String, dynamic>? lists = listDoc.data();
        //Map to List casting
        if (lists != null) {
          List<String> dataList =
              lists.entries.map((entry) => entry.key).toList();
          return dataList;
        } else {
          return [];
        }
      } catch (e) {
        throw Exception("Listeler getirilemedi! " + e.toString());
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  Future<bool> isListContainsMovie(
      {required String listName, required String movieId}) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      var listDoc = await listCollection.doc(user.uid).get();
      var listData = listDoc.data();
      if (listData != null && listData.containsKey(listName)) {
        var list = listData[listName];
        if (list is List) {
          return list.contains(movieId);
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  Future<void> setMovieList({required String listName}) async {
    User? user = firebaseAuth.currentUser;
    if (listName == "watch-later") {
      throw Exception("Bu isimde bir liste bulunuyor.");
    }

    var userLists = await getLists();
    for (var list in userLists) {
      if (list == listName) {
        throw Exception("Bu isimde bir liste bulunuyor.");
      }
    }
    if (user != null) {
      try {
        try {
          await listCollection.doc(user.uid).update({
            listName: null,
          });
        } catch (error) {
          await listCollection.doc(user.uid).set({
            listName: null,
          });
        }
      } catch (e) {
        throw Exception("Bir hata oluştu.Liste oluşturulamadı" + e.toString());
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  Future<void> setWatchLater({required String movieId}) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        try {
          await listCollection.doc(user.uid).update({
            "watch-later": FieldValue.arrayUnion([movieId]),
          });
        } catch (error) {
          await listCollection.doc(user.uid).set({
            "watch-later": FieldValue.arrayUnion([movieId]),
          });
        }
      } catch (e) {
        throw Exception("Daha sonra izle listesine eklenemedi." + e.toString());
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  Future<void> removeListedMovie(
      {required String movieId, required String listName}) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        await listCollection.doc(user.uid).update({
          listName: FieldValue.arrayRemove([movieId]),
        });
      } catch (error) {
        throw Exception('Bir hata oluştu: $error');
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  Future<List<dynamic>> getMovieByList({required String listName}) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        var lists = await listCollection.doc(user.uid).get();
        var movies = await lists.get(listName);
        return movies;
      } catch (e) {
        throw Exception('Bir hata oluştu: $e');
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  Future<void> deleteList({required String listName}) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        await listCollection.doc(user.uid).update({listName : FieldValue.delete()});
      } catch (error) {
        throw Exception('Bir hata oluştu: $error');
      }
    } else {
      throw Exception('Kullanıcı bulunamadı!');
    }
  }

  
}
