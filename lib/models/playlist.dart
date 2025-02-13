import 'package:shuffle_enforcer/models/track.dart';
import 'package:shuffle_enforcer/utils/api.dart';

class Playlist {
  String id;
  String name;
  String? description;
  String? owner;
  String href;
  String? imageUrl;
  List<Track>? tracks;

  Playlist(this.id, this.name, this.description, this.owner, this.href,
      this.imageUrl,
      [this.tracks]);

  @override
  String toString() {
    return "Playlist[id:$id, name: $name, owner: $owner]";
  }

  Future<List<Track>> getTracks() async {
    tracks ??= await getPlaylistTracks(id);

    return tracks!;
  }
}
