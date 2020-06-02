

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';

import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';
import 'package:liber2/search.dart';

// import 'package:liber2/search.dart';
import 'package:liber2/torrent.dart';

import 'package:url_launcher/url_launcher.dart';

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
      body: Builder(builder: (context){
       queryData = MediaQuery.of(context);

        return  Container(
        
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            // Text(
            //   'Popular Movies',
            //   style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //       color: Colors.white,
            //       fontSize: 15),
            // ),
            HorizontalList(0),
            // SizedBox(
            //   height: 10,
            // ),
           
          ],
        ),
      );
      }),
      
     
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,

      //   // elevation: 10,
      //   items: <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       backgroundColor: Colors.grey[900],
      //       icon: Icon(Icons.local_movies),
      //       title: Text('Movie'),
      //     ),
      //     BottomNavigationBarItem(
      //       backgroundColor: Colors.grey[900],
      //       icon: Icon(Icons.tv),
      //       title: Text('TV'),
      //     ),
      //     BottomNavigationBarItem(
      //       backgroundColor: Colors.grey[900],
      //       icon: Icon(Icons.language),
      //       title: Text('Language'),
      //     ),
      //     BottomNavigationBarItem(
      //       backgroundColor: Colors.black87,
      //       icon: Icon(Icons.info_outline),
      //       title: Text('About'),
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.greenAccent[400],
      //   unselectedItemColor: Colors.grey,
      //   backgroundColor: Colors.black26,

      //   onTap: _onItemTapped,
      // ),
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

class MovieDetailPage extends StatelessWidget {
  final MovieData movies;

  MovieDetailPage(this.movies);

  //function for adding trackers to the magnet link

  String print_trackers() {
    var tr = '&tr=' +
        Uri.encodeComponent('udp://tracker.coppersurfer.tk:6969/announce');
    tr += '&tr=' + Uri.encodeComponent('udp://9.rarbg.to:2920/announce');
    tr += '&tr=' + Uri.encodeComponent('udp://tracker.opentrackr.org:1337');
    tr += '&tr=' +
        Uri.encodeComponent('udp://tracker.internetwarriors.net:1337/announce');
    tr += '&tr=' +
        Uri.encodeComponent(
            'udp://tracker.leechers-paradise.org:6969/announce');
    tr += '&tr=' +
        Uri.encodeComponent('udp://tracker.coppersurfer.tk:6969/announce');
    tr += '&tr=' +
        Uri.encodeComponent('udp://tracker.pirateparty.gr:6969/announce');
    tr +=
        '&tr=' + Uri.encodeComponent('udp://tracker.cyberia.is:6969/announce');
    return tr;
  }

//getting torrent details of a movie

  Future<List<TorrentModel>> getTorrentDetails(
      String title, String year) async {
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

  @override
  Widget build(BuildContext context) {
    void onTorrentButtonPressed() {
      showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        )),
        backgroundColor: Colors.grey[900],
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: FutureBuilder(
              future: getTorrentDetails(movies.title, '1080p'),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  // listHeight = snapshot.data.length * 100.0;
                  return ListView.separated(
                    physics: BouncingScrollPhysics(),
                    separatorBuilder: (context, index) => Divider(
                      height: 5,
                      color: Colors.black,
                    ),
                    itemCount:
                        snapshot.data.length > 10 ? 10 : snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 100,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                width: 250,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      height: 40,
                                      child: Text(
                                        snapshot.data[index].name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                        maxLines: 5,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Icon(
                                          Icons.keyboard_arrow_up,
                                          color: Colors.grey[400],
                                        ),
                                        Text(
                                          snapshot.data[index].seeders,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.grey[400],
                                        ),
                                        Text(
                                          snapshot.data[index].leechers,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'Size : ' +
                                              (double.parse(snapshot
                                                          .data[index].size) /
                                                      (1024 * 1024 * 1024))
                                                  .toStringAsFixed(2) +
                                              ' GB',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  var magnet = "magnet:?xt=urn:btih:" +
                                      snapshot.data[index].info_hash +
                                      '&xl=' +
                                      snapshot.data[index].size +
                                      '&dn=' +
                                      snapshot.data[index].name +
                                      '&tr=' +
                                      print_trackers();
                                  print(magnet);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyApp2(
                                        magnet: magnet,
                                        torrentName: snapshot.data[index].name,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.file_download,
                                  color: Colors.grey[400],
                                ),
                                onPressed: () {
                                  var magnet = "magnet:?xt=urn:btih:" +
                                      snapshot.data[index].info_hash +
                                      '&xl=' +
                                      snapshot.data[index].size +
                                      '&dn=' +
                                      snapshot.data[index].name +
                                      '&tr=' +
                                      print_trackers();

                                  try {
                                    _launchURL() async {
                                      var url = magnet;
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.black87,
                                            content: Text(
                                                'Download works only if you have a torrent client installed'),
                                          ),
                                        );
                                      }
                                    }

                                    _launchURL();
                                  } catch (errorPropertyTextConfiguration) {
                                    print(errorPropertyTextConfiguration);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Container(
                    child: Center(
                      child: SpinKitRing(
                        color: Colors.white,
                        size: 50.0,
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.greenAccent[400],
        ),
        elevation: 10,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // physics: BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Hero(
                    tag: movies.title,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        child: Image.network(
                          movies.poster_path,
                          height: 300,
                          width: 200,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              // Image.network(movies.backdrop_path),

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  movies.title,
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                  ),
                  softWrap: true,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    double.parse(movies.vote_average).toString() ,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.amber,
                  ),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              Text(
                ' Year of release: ' + movies.release_date.substring(0, 4),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        movies.overview,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.white)),
                      color: Colors.white,
                      child: Text(
                        'Torrents',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[850],
                        ),
                      ),
                      onPressed: () => onTorrentButtonPressed(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovieData {
  final String title;
  final String overview;
  final String poster_path;
  final String backdrop_path;
  final String vote_average;
  final String release_date;

  MovieData(
      {this.title,
      this.overview,
      this.poster_path,
      this.backdrop_path,
      this.vote_average,
      this.release_date});
}

class TorrentModel {
  String name;
  String info_hash;
  String leechers;
  String seeders;
  String size;
  TorrentModel(
      {this.info_hash, this.leechers, this.name, this.seeders, this.size});
}

//torrent streamer

class HorizontalList extends StatelessWidget {
  final int index;
  HorizontalList(this.index);

  Future<List<MovieData>> _getMovieDetails(String type) async {
    var movieData;

    movieData = await get(
        'https://api.themoviedb.org/3/movie/$type?api_key=68f5e159270aa45cb28754ce59701d21&language=en-US&page=1');

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
              'http://image.tmdb.org/t/p/w500/' + m["backdrop_path"]);

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
          return Container(
            height: queryData.size.height-112,
            child: GridView.builder(
              // shrinkWrap: true,
              scrollDirection: Axis.vertical,
              // physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.length-2,
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
//vertical
