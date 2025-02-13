import 'package:flutter/material.dart';
import 'package:shuffle_enforcer/models/playlist.dart';
import 'package:shuffle_enforcer/models/track.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(playlist.name),
            ),
            body: FutureBuilder(
              future: playlist.getTracks(),
              builder: (context, AsyncSnapshot<List<Track>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Track track = snapshot.data![index];
                        String subtitle = track.artists.join(", ");

                        if (track.beforeThis != null) {
                          subtitle +=
                              "\n\nPlays after ${track.beforeThis!.name}";
                        }

                        Widget trackWidget = ListTile(
                            title: Text(track.name),
                            subtitle: Text(subtitle),
                            leading: Image.network(track.albumArtUrl),
                            trailing: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.more_vert)),
                            isThreeLine: track.beforeThis != null);

                        List<Widget> trackAndDivider = index == 0
                            ? [trackWidget]
                            : [const Divider(), trackWidget];
                        return Column(children: trackAndDivider);
                      });
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error retrieving tracks in playlist."));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )));
  }
}
