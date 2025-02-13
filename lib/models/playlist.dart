import 'package:shuffle_enforcer/models/track.dart';

class Playlist {
  String id;
  String name;
  String? description;
  String? owner;
  String href;
  String? imageUrl;
  List<Track> tracks;

  Playlist(this.id, this.name, this.description, this.owner, this.href,
      this.imageUrl,
      [this.tracks = const []]);

  @override
  String toString() {
    return "Playlist[id:$id, name: $name, owner: $owner]";
  }
}
