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
  late Future<List<Playlist>> playlists;

  @override
  void initState() {
    playlists = getPlaylistListing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: playlists,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List<Playlist> playlists = snapshot.data;

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: playlists.length,
              itemBuilder: (BuildContext context, int index) {
                Playlist playlist = playlists[index];
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
            return const Center(
                child: Text("Error retrieving playlists or devices."));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
