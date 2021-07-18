import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:liber2/widgets/movie_detail_page.dart';

import 'main.dart';
import 'models/movie_data.dart';

class TorrentModel {
  String name;
  String info_hash;
  String leechers;
  String seeders;
  String size;
  TorrentModel(
      {this.info_hash, this.leechers, this.name, this.seeders, this.size});
}

Future<List<TorrentModel>> getTorrentDetails(String title, String year) async {
  var torrentData =
      await get('https://api.apibay.workers.dev/q.php?q=$title+' '+$year');
  // print(torrentData.body);
  var jsonTorrentData = jsonDecode(torrentData.body);
  // print(jsonTorrentData);

  List<TorrentModel> torrents = [];

  for (var t in jsonTorrentData) {
    TorrentModel torrent = TorrentModel(
      name: t["name"],
      info_hash: t["info_hash"],
      leechers: t["leechers"],
      seeders: t["seeders"],
      size: t["size"],
    );
    // print(torrent.name);
    torrents.add(torrent);
    // print(torrents.name);
  }
  return torrents;
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String movieName = 'joker';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(
            color: Colors.greenAccent[400],
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        elevation: 10,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Container(
          child: Column(
            children: <Widget>[
              TextField(
                autofocus: true,
                autocorrect: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintText: "Search a movie...",
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.w300, color: Colors.grey),
                  suffix: Icon(
                    Icons.search,
                    color: Colors.greenAccent[400],
                  ),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (text) {
                  setState(() {
                    movieName = text;
                  });

                  // print(text);
                  // getTorrentDetails(text,"");
                  // HorizontalList(text);
                },
              ),
              HorizontalList(movieName),
            ],
          ),
        ),
      ),
    );
  }
}

void onSearch() {}

class HorizontalList extends StatelessWidget {
  final String movieName;
  HorizontalList(this.movieName);

  Future<List<MovieData>> _getMovieDetails(String movieName) async {
    var movieData;

    movieData = await get(
        'https://api.themoviedb.org/3/search/movie?api_key=68f5e159270aa45cb28754ce59701d21&language=en-US&query=$movieName&page=1&include_adult=false');

    print(movieData.body);
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
              'http://image.tmdb.org/t/p/w500/' + m["backdrop_path"]);

      // vote_average: double.parse(m["vote_average"]));
      movies.add(movie);
    }
    print(movies.length);
    return movies;
  }

  var appBar = AppBar().preferredSize.height;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getMovieDetails(movieName),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Container(
            height: queryData.size.height - 112,
            child: GridView.builder(
              // shrinkWrap: true,
              scrollDirection: Axis.vertical,
              // physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.length - 2,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),

              itemBuilder: (BuildContext context, int index) {
                return Container(
                  color: Colors.grey[900],
                  // height: 280,
                  child: GestureDetector(
                      child: Hero(
                        tag: snapshot.data[index].title,
                        child: Card(
                          color: Colors.transparent,
                          shadowColor: Colors.black,
                          elevation: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              color: Colors.transparent,

                              // height: 250,
                              child: Image.network(
                                snapshot.data[index].poster_path,
                                fit: BoxFit.cover,
                                height: 250,
                                width: 180,
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailPage(snapshot.data[index]),
                          ),
                        );
                      }),
                );
              },
            ),
          );
        } else {
          return Column(
            children: <Widget>[
              Container(
                // height: 210,
                child: Center(
                  child: SpinKitWave(
                    color: Colors.white,
                    size: 50.0,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
