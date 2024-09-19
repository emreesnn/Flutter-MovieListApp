import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

var apiKey = dotenv.env['API_KEY'];

class getDataFromApi {

  late final String uri;
  List<dynamic> popularMovies = [];
  List<dynamic> trendMovies = [];
  List<dynamic> movieDetail = [];

  Future getData({String? movieId}) async {
    try {
      await fetchGenreList();
      popularMovies = await fetchPopularMovies();
      trendMovies = await fetchTrendMovies();
    } catch (e) {
      print('getData Error: $e');
    }
  }

  Future getMovieDetail({required String movieId}) async {
    try {
      movieDetail = await fetchMovie(movieId: movieId);
    } catch (e) {
      print('getMovieDetail Hatası $e');
    }
  }

  Future<List<dynamic>> fetchMovie({required String movieId}) async {
    List<dynamic> movieDetail = [];
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&language=tr-TR&append_to_response=credits'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      movieDetail = [
        {
          'id': data['id'],
          'title': data['title'],
          'posterPath': data['poster_path'],
          'backdropPath': data['backdrop_path'],
          'genres': data['genres'],
          'release_date': data['release_date'],
          'runtime': data['runtime'],
          'vote_average': data['vote_average'],
          'overview': data['overview'],
        }
      ];

      return movieDetail;
    } else {
      return movieDetail;
    }
  }

  //Genreleri olduğu gibi almak için kullanıyorum daha sonra genreye göre film çekme işleminde kullanılacak
  Future<List<dynamic>> getGenreList() async {
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey&language=tr-TR'),
    );
    List<dynamic> genreList = [];
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      genreList = data['genres'];
    }

    return genreList;
  }

  Future<Map<String, List<dynamic>>> getMoviesByGenres() async {
     List<dynamic> genreList = await getGenreList();
     Map<String, List<dynamic>> movies = {};
    for (var genre in genreList) {
      var genreId = genre['id'];
      var url =
          "https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&include_adult=false&include_video=false&language=tr-TR&page=1&sort_by=popularity.desc&with_genres=$genreId";

      final response = await http.get(
        Uri.parse(url),
      );

      List<dynamic> results = [];
      if (response.statusCode == 200) {
        Map<String, dynamic> datas = json.decode(response.body);
        List<dynamic> movieResults = datas['results'];
        for (var data in movieResults) {
          results.add({
            'id': data['id'],
            'title': data['title'],
            'posterPath': data['poster_path']
          });
        }
      }
      movies[genre['name']] = results;
    }
    return movies;
  }

  Future<List<dynamic>> searchMovie({required String query}) async {
    var url =
        "https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query&include_adult=true&language=tr-TR&page=1";
    final response = await http.get(
      Uri.parse(url),
    );
    List<dynamic> results = [];

    if (response.statusCode == 200) {
      Map<String, dynamic> datas = json.decode(response.body);
      List<dynamic> movieResults = datas['results'];
      for (var data in movieResults) {
        results.add({
          'id': data['id'],
          'title': data['title'],
          'backdropPath': data['backdrop_path']
        });
      }
    }
    return results;
  }
}

Future<List<Movie>> fetchPopularMovies() async {
  List<Movie> movies = [];
  final response = await http.get(
    Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=tr-TR'),
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> results = data['results'];
    for (var result in results) {
      // Her bir sonuç için Movie nesnesi oluştur
      Movie movie = Movie.fromJson(result);
      // Movie nesnesinin tür ID'lerini String karşılıklarına dönüştür
      movie.genresString = genreIdToString(genreIdList: movie.genres);

      // Oluşturulan Movie nesnesini listeye ekle
      movies.add(movie);
    }

    return movies;
  } else {
    return nullList;
  }
}

Future<List<Movie>> fetchTrendMovies() async {
  List<Movie> movies = [];
  final response = await http.get(
    Uri.parse(
        'https://api.themoviedb.org/3/trending/movie/week?api_key=$apiKey&language=tr-TR'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> results = data['results'];
    for (var result in results) {
      // Her bir sonuç için Movie nesnesi oluştur
      Movie movie = Movie.fromJson(result);
      // Movie nesnesinin tür ID'lerini String karşılıklarına dönüştür
      movie.genresString = genreIdToString(genreIdList: movie.genres);

      // Oluşturulan Movie nesnesini listeye ekle
      movies.add(movie);
    }

    return movies;
  } else {
    return nullList;
  }
}

List<Movie> nullList = [
  Movie(
    id: 0,
    title: 'Hata',
    posterPath: 'null',
    voteAverage: '0.0',
    releaseDate: "0/0/2000",
    genres: [0],
  )
];

class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String voteAverage;
  final String releaseDate;
  final List<int> genres;
  List<String> genresString;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genres,
    this.genresString = const [],
  });
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
      voteAverage: json['vote_average'].toString().substring(0, 3),
      releaseDate: json['release_date'],
      genres: json['genre_ids'].cast<int>(),
    );
  }
}

Map<int, String> genreNames = {};
Future<void> fetchGenreList() async {
  //genreNames doluysa içini boşalt çünkü birden fazla kez çağırılırsa tekrar doldurulmasın.

  final response = await http.get(
    Uri.parse(
        'https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey&language=tr-TR'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> genreList = data['genres'];

    // genreList içindeki her bir tür nesnesini Map'e ekleyelim
    for (var genre in genreList) {
      genreNames[genre['id']] = genre['name'];
    }
  }
}

List<String> genreIdToString({required List<int> genreIdList}) {
  List<String> movieGenres = [];

  for (var genreId in genreIdList) {
    movieGenres.add(genreNames[genreId].toString());
  }

  return movieGenres;
}
