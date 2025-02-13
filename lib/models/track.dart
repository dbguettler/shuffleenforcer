class Track {
  String id;
  String name;
  List<String> artists;
  String albumArtUrl;
  Track? after;
  Track? before;

  Track(this.id, this.name, this.artists, this.albumArtUrl,
      [this.before, this.after]);

  @override
  String toString() {
    return "Track[id:$id, name: $name, artists: ${artists.join(",")}]";
  }
}
