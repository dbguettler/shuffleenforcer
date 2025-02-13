import 'package:flutter/material.dart';
import 'package:shuffle_enforcer/models/playlist.dart';
import 'package:shuffle_enforcer/playlist_view.dart';
import 'package:shuffle_enforcer/utils/api.dart';

class PlaylistListing extends StatefulWidget {
  const PlaylistListing({
    super.key,
  });

  @override
  State<PlaylistListing> createState() => _PlaylistListingState();
}

class _PlaylistListingState extends State<PlaylistListing> {
  Future<List<Playlist>> playlists = getPlaylistListing();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: playlists,
        builder: (context, AsyncSnapshot<List<Playlist>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                Playlist playlist = snapshot.data![index];
                Widget playlistWidget = InkWell(
                  child: ListTile(
                      title: Text(playlist.name),
                      subtitle: Text(playlist.owner ?? "Unavailable"),
                      leading: playlist.imageUrl != null
                          ? Image.network(playlist.imageUrl!)
                          : const Icon(Icons.music_note)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PlaylistView(playlist: playlist)));
                  },
                );

                List<Widget> playlistAndDivider = index == 0
                    ? [playlistWidget]
                    : [const Divider(), playlistWidget];
                return Column(children: playlistAndDivider);
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error retrieving playists."));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
