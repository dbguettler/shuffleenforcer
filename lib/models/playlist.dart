import 'package:shuffle_enforcer/models/constraint.dart';
import 'package:shuffle_enforcer/models/track.dart';
import 'package:shuffle_enforcer/utils/api.dart';
import 'package:shuffle_enforcer/utils/constraints.dart';
import 'package:collection/collection.dart';

class Playlist {
  String id;
  String name;
  String? description;
  String? owner;
  String href;
  String? imageUrl;
  List<Track>? _tracks;

  Playlist(
    this.id,
    this.name,
    this.description,
    this.owner,
    this.href,
    this.imageUrl,
  );

  @override
  String toString() {
    return "Playlist[id:$id, name: $name, owner: $owner]";
  }

  Future<List<Track>> getTracks() async {
    if (_tracks == null) {
      _tracks = await getPlaylistTracks(id);
      // Load constraints into tracks
      List<Constraint> constraints = await getConstraints(id);

      for (Constraint c in constraints) {
        Track? first =
            _tracks!.singleWhereOrNull((element) => element.id == c.firstId);

        Track? second =
            _tracks!.singleWhereOrNull((element) => element.id == c.secondId);

        if (first == null || second == null) {
          continue;
        }

        first.afterThis = second;
        second.beforeThis = first;
      }
    }

    return _tracks!;
  }
}
