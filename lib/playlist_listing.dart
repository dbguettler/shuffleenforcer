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

            return Column(children: [
              Padding(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 5, left: 20, right: 20),
                  child: Row(spacing: 10, children: [
                    const Text(
                      "Content provided by:",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Image.asset(
                                "assets/Spotify_Full_Logo_RGB_Black.png")))
                  ])),
              const Divider(),
              Expanded(
                  child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: playlists.length,
                itemBuilder: (BuildContext context, int index) {
                  Playlist playlist = playlists[index];
                  Widget playlistWidget = InkWell(
                    child: ListTile(
                        title: Text(playlist.name),
                        subtitle: Text(playlist.owner ?? "Unavailable"),
                        leading: playlist.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Image.network(playlist.imageUrl!))
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
              ))
            ]);
          } else if (snapshot.hasError) {
            return const Center(
                child: Text("Error retrieving playlists or devices."));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
