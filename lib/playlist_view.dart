import 'package:flutter/material.dart';
import 'package:shuffle_enforcer/models/playlist.dart';
import 'package:shuffle_enforcer/models/track.dart';
import 'package:shuffle_enforcer/utils/api.dart';
import 'package:shuffle_enforcer/utils/constraints.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(playlist.name),
              actions: [
                IconButton(
                    icon: const Icon(Icons.shuffle),
                    onPressed: () async {
                      await shuffleAndPlay(playlist);
                    })
              ],
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
                                onPressed: () async {
                                  String? otherTrackId = await showDialog<
                                          String?>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        String? selectedId;

                                        List<DropdownMenuEntry<String>>
                                            dropdownItems = snapshot.data!
                                                .map<DropdownMenuEntry<String>>(
                                                    (t) => DropdownMenuEntry<
                                                            String>(
                                                        value: t.id,
                                                        label: t.name))
                                                .toList();
                                        //Remove self from list and add "None" option
                                        dropdownItems.removeAt(index);
                                        dropdownItems.insert(
                                            0,
                                            const DropdownMenuEntry(
                                                value: "None", label: "None"));

                                        DropdownMenu<String> menu =
                                            DropdownMenu(
                                          dropdownMenuEntries: dropdownItems,
                                          menuHeight: MediaQuery.sizeOf(context)
                                                  .height /
                                              3,
                                          onSelected: (value) {
                                            selectedId = value;
                                          },
                                          initialSelection:
                                              track.beforeThis?.id ?? "None",
                                        );

                                        return AlertDialog(
                                          title: const Text("Edit Constraint"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("Play ${track.name} after:"),
                                              menu
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop<String?>(
                                                        context, null),
                                                child: const Text("Cancel")),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop<String?>(
                                                        context, selectedId),
                                                child: const Text("OK"))
                                          ],
                                        );
                                      });
                                  if (otherTrackId != null &&
                                      otherTrackId != "None") {
                                    Track otherTrack = snapshot.data!
                                        .singleWhere((element) =>
                                            element.id == otherTrackId);

                                    track.beforeThis = otherTrack;
                                    otherTrack.afterThis = track;
                                    await setConstraint(
                                        playlist.id, otherTrack.id, track.id);
                                  } else if (otherTrackId == "None") {
                                    String? firstTrack =
                                        await removeConstraintSecond(
                                            playlist.id, track.id);
                                    track.beforeThis = null;
                                    if (firstTrack != null) {
                                      Track otherTrack = snapshot.data!
                                          .singleWhere((element) =>
                                              element.id == firstTrack);
                                      otherTrack.afterThis = null;
                                    }
                                  }
                                },
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
