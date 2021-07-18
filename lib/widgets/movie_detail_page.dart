import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:liber2/models/movie_data.dart';
import 'package:liber2/models/torrent.dart';
import 'package:url_launcher/url_launcher.dart';

import '../torrent.dart';

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
    var torrentData = await http
        .get('https://api.apibay.workers.dev/q.php?q=$title+' '+$year');
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
                                      builder: (context) =>
                                          TorrentStreamerScreen(
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
                    double.parse(movies.vote_average).toString(),
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
