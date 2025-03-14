class Track {
  String id;
  String name;
  List<String> artists;
  String albumArtUrl;
  Track? afterThis;
  Track? beforeThis;
  String spotifyUrl;

  Track(this.id, this.name, this.artists, this.albumArtUrl, this.spotifyUrl,
      [this.beforeThis, this.afterThis]);

  @override
  String toString() {
    return "Track[id:$id, name: $name, artists: ${artists.join(",")}]";
  }
}
