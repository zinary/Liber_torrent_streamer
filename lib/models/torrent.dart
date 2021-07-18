class TorrentModel {
  String name;
  String info_hash;
  String leechers;
  String seeders;
  String size;
  TorrentModel(
      {this.info_hash, this.leechers, this.name, this.seeders, this.size});
}
