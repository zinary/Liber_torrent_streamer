import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';

import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';
import 'package:liber2/search.dart';

import 'package:liber2/widgets/movies_grid_view.dart';

import 'models/movie_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  final Directory saveDir = await getExternalStorageDirectory();
  await TorrentStreamer.init();
  runApp(MyApp());
}

MediaQueryData queryData;

class StaticConstants {
  static bool hasdata = false;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liber2',
      theme: ThemeData(
        primaryColor: Colors.grey[900],
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[900],
        fontFamily: 'Product Sans',
        textTheme: TextTheme(
          bodyText1: TextStyle(),
          bodyText2: TextStyle(),
        ).apply(
          bodyColor: Colors.grey[400],
          displayColor: Colors.blue,
        ),
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

// List<String> movieType = [
//   'popular',
//   'top_rated',
//   'now_playing',
// ];

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
//HOME page list

  @override
  Widget build(BuildContext context) {
    // MediaQueryData queryData;
    // queryData = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        backgroundColor: Colors.grey[900],
        title: RichText(
          text: TextSpan(
            text: 'Liber',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            children: <TextSpan>[
              TextSpan(
                  text: '.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent[400])),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        queryData = MediaQuery.of(context);

        return Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Popular Movies',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15),
                ),
              ),
              HorizontalList(0),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,

        // elevation: 10,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.grey[900],
            icon: Icon(Icons.local_movies),
            label: 'Movie',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.grey[900],
            icon: Icon(Icons.tv),
            label: 'TV',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.grey[900],
            icon: Icon(Icons.language),
            label: 'Language',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.black87,
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.greenAccent[400],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black26,

        onTap: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        // heroTag: 's',
        backgroundColor: Colors.greenAccent[400],
        child: Icon(Icons.search),
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(),
            ),
          );
        },
      ),
    );
  }
}

//torrent streamer

class HorizontalList extends StatelessWidget {
  final int index;
  HorizontalList(this.index);

  Future<List<MovieData>> _getMovieDetails(String type) async {
    var movieData = await get(
        'https://api.themoviedb.org/3/movie/$type?api_key=API_KEY&language=en-US&page=1');

    print(type);

    var jsonMovieData = jsonDecode(movieData.body);

    List<MovieData> movies = [];

    for (var m in jsonMovieData["results"]) {
      MovieData movie = MovieData(
          title: m["title"],
          poster_path: 'http://image.tmdb.org/t/p/w500/' + m["poster_path"],
          overview: m["overview"],
          vote_average: m["vote_average"].toString(),
          release_date: m["release_date"],
          backdrop_path:
              "http://image.tmdb.org/t/p/w500/${m["backdrop_path"]}");

      // vote_average: double.parse(m["vote_average"]));
      movies.add(movie);
    }
    return movies;
    // print(movies.length);
  }

  var appBar = AppBar().preferredSize.height;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getMovieDetails('popular'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data.toString());
          return MoviesGridView(snapshot: snapshot);
        } else {
          return Container(
            height: double.infinity,
            child: Center(
              child: SpinKitWave(
                color: Colors.red,
                size: 50.0,
              ),
            ),
          );
        }
      },
    );
  }
}
