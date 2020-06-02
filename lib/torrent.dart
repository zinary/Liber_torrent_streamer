

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';

class Constants {
  static const String ClearCache = 'Clear Cache';
  static const String CopyMagnet = 'Copy Magnet';

  static const List<String> choices = <String>[
    ClearCache,
    CopyMagnet,
  ];
}

BuildContext scaffoldContext;

class Torrent {
  static var magnet_link;
  static var torrent_name;
}

Widget build(BuildContext context) {
  scaffoldContext = context;
  return Container(height: 8, width: 8);
}

class MyApp2 extends StatelessWidget {
  final String magnet;
  final String torrentName;

  MyApp2({
    this.magnet,
    this.torrentName,
  });

  @override
  Widget build(BuildContext context) {
    void choiceAction(String choice) {
      if (choice == Constants.ClearCache) {
        print('ClearCache');
        TorrentStreamer.clean();
      } else if (choice == Constants.CopyMagnet) {
        print('CopyMagnet');
        Clipboard.setData(ClipboardData(text: magnet));
      }
    }

    Torrent.magnet_link = magnet;
    Torrent.torrent_name = torrentName;
    return MaterialApp(
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
      home: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,color: Colors.greenAccent[400],),
                color: Colors.grey[800],
                onSelected: choiceAction,
                itemBuilder: (BuildContext context) {
                  return Constants.choices.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(
                        choice,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList();
                },
              )
            ],
            leading: BackButton(
                color: Colors.greenAccent[400],
                onPressed: () {
                  TorrentStreamer.stop();

                  Navigator.pop(context);
                }),

            title: Text(
              'Stream torrent',
              style: TextStyle(
                color: Colors.greenAccent[400],
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            ),
            // centerTitle: true,
            // backgroundColor: Colors.grey[900],
            elevation: 20,
          ),
          body: TorrentStreamerView()),
    );
  }
}

class MySpacer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 8, width: 8);
  }
}

class TorrentStreamerView extends StatefulWidget {
  @override
  _TorrentStreamerViewState createState() => _TorrentStreamerViewState();
}

class _TorrentStreamerViewState extends State<TorrentStreamerView> {
  final String magnet;
  final String torrentName;

  _TorrentStreamerViewState({this.magnet, this.torrentName});

  // TextEditingController _controller;
  String torrentLink;
  String torrentName1;

  bool isStopped = false;
  bool isDownloading = false;
  bool isStreamReady = false;
  bool isFetchingMeta = false;
  bool hasError = false;
  Map<dynamic, dynamic> status;

  @override
  void initState () {
    super.initState();
    torrentLink = Torrent.magnet_link;
    torrentName1 = Torrent.torrent_name;
    print(torrentLink);
    // _controller = TextEditingController();

    _addTorrentListeners();
    _startDownload();
 
    //  openPlayerAutomatic(isStreamReady);
     
    
  }

  @override
  void dispose() {
    TorrentStreamer.stop();
    TorrentStreamer.removeEventListeners();
    TorrentStreamer.clean();

    super.dispose();
  }

  void resetState() {
    setState(() {
      isDownloading = false;
      isStreamReady = false;
      isFetchingMeta = false;
      hasError = false;
      status = null;
    });
  }

  void _addTorrentListeners() {
    TorrentStreamer.addEventListener('started', (_) {
      resetState();
      setState(() {
        isDownloading = true;
        isFetchingMeta = true;
      });
    });

    TorrentStreamer.addEventListener('prepared', (_) {
      setState(() {
        isDownloading = true;
        isFetchingMeta = false;
      });
    });

    TorrentStreamer.addEventListener('progress', (data) {
      setState(() => status = data);
    });

    TorrentStreamer.addEventListener('ready', (_) {
      setState(() {
        TorrentStreamer.launchVideo();
        isStreamReady = true;
        
      }
      
       );
    });

    TorrentStreamer.addEventListener('stopped', (_) {
      resetState();
    });

    TorrentStreamer.addEventListener('error', (_) {
      setState(() => hasError = true);
    });
  }

  int _toKBPS(double bps) {
    return (bps / (8 * 1024)).floor();
  }

  Future<void> _cleanDownloads(BuildContext context) async {
    await TorrentStreamer.clean();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black87,
        content: Row(
          children: <Widget>[
            Icon(Icons.delete_outline),
            SizedBox(
              width: 10,
            ),
            Text('Cleared torrent cache!'),
          ],
        ),
      ),
    );
  }


void  openPlayerAutomatic(Future isReady) async {
    
    await isReady ? TorrentStreamer.launchVideo() : null;

  

}

  Future<void> _startDownload() async {
    await TorrentStreamer.stop();
    await TorrentStreamer.start(torrentLink);
    isStopped = false;
  }

  Future<void> _openVideo(BuildContext context) async {
    await TorrentStreamer.launchVideo();
    // Navigator.of(context).pop();
  }

  Widget _buildInput(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        MySpacer(),
        Text(
          torrentName1,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        MySpacer(),
        MySpacer(),
        MySpacer(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
              'Note:\nTorrent streaming is experimental, You might face issues while seeking videos. \nPress open player to play the video on external video player'),
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     FlatButton(
        //       shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(18.0),
        //           side: BorderSide(color: Colors.white)),
        //       color: Colors.white,
        //       child: Text(
        //         'Clear Cache',
        //         style: TextStyle(
        //           fontWeight: FontWeight.bold,
        //           color: Colors.grey[850],
        //         ),
        //       ),
        //       onPressed: () => _cleanDownloads(context),
        //     ),
        //     SizedBox(
        //       width: 30,
        //     ),
        //     FlatButton(
        //       shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(18.0),
        //           side: BorderSide(color: Colors.white)),
        //       color: Colors.white,
        //       onPressed: () {
        //         Clipboard.setData(ClipboardData(text: torrentLink));
        //         final snackBar = SnackBar(
        //           behavior: SnackBarBehavior.floating,
        //           backgroundColor: Colors.black87,
        //           content: Row(
        //             children: <Widget>[
        //               Icon(
        //                 Icons.link,
        //                 color: Colors.grey[400],
        //               ),
        //               SizedBox(
        //                 width: 10,
        //               ),
        //               Text('Magnet Link copied to clipboard'),
        //             ],
        //           ),
        //         );
        //         Scaffold.of(context).showSnackBar(snackBar);
        //       },
        //       child: Text(
        //         'Copy Magnet',
        //         style: TextStyle(
        //           fontWeight: FontWeight.bold,
        //           color: Colors.grey[900],
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        MySpacer(),
        Visibility(
          visible: (!isStreamReady && !isStopped ? true : false),
          child: SpinKitWave(
            color: Colors.grey[400],
            size: 50.0,
          ),
        ),
        Visibility(
          visible: isStopped ? true : false,
          child: FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            color: Colors.greenAccent[400],
            child: Text(
              'Start Streaming',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[850],
              ),
            ),
            onPressed: () => _startDownload(),
          ),
        ),
      ],
    );
  }

  Widget _buildTorrentStatus(BuildContext context) {
    if (hasError) {
      return Text('Failed to download torrent!');
    } else if (isDownloading) {
      String statusText = '';
      if (isFetchingMeta) {
        statusText = 'Fetching meta data';
      } else {
        statusText = 'Progress: ${progress.floor().toString()}% - ' +
            'Speed: ${_toKBPS(speed)} KB/s';
      }

      return Column(
        children: <Widget>[
          Visibility(
            visible: isStreamReady ? false : true,
            child: Text(
              'Please wait while loading',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          MySpacer(),
          MySpacer(),
          Text(statusText,style: TextStyle(color: Colors.white,fontSize: 15),),
          MySpacer(),
          // LinearProgressIndicator(
          //     valueColor:
          //         AlwaysStoppedAnimation<Color>(Colors.greenAccent[400]),
          //     value: !isFetchingMeta ? progress / 100 : null),

          MySpacer(),

          Row(
            children: <Widget>[
              FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(
                    ' Open Player',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[850],
                    ),
                  ),
                  color: Colors.greenAccent[400],
                  onPressed: isStreamReady ? () => _openVideo(context) : null),
              SizedBox(
                width: 30,
              ),
              FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  color: Colors.red,
                  child: Text(
                    'Stop Streaming',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isStopped = true;
                      TorrentStreamer.stop();
                    });
                  }),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          // FlatButton(
          //   color: Colors.greenAccent[400],
          //   child: Text(
          //     'Clear Cache',
          //     style: TextStyle(
          //       fontWeight: FontWeight.bold,
          //       color: Colors.grey[850],
          //     ),
          //   ),
          //   onPressed: () => _cleanDownloads(context),
          // ),
        ],
      );
    } else {
      return Container(height: 0, width: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _buildInput(context),
          MySpacer(),
          MySpacer(),
          _buildTorrentStatus(context)
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
      ),
      padding: EdgeInsets.all(16),
    );
  }

  bool get isCompleted => progress == 100;

  double get progress => status != null ? status['progress'] : 0;

  double get speed => status != null ? status['downloadSpeed'] : 0;
}
