import 'package:flutter/material.dart';
import 'package:shuffle_enforcer/models/track.dart';
import 'package:shuffle_enforcer/utils/constraints.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackListItem extends StatefulWidget {
  const TrackListItem(
      {super.key,
      required this.track,
      required this.playlistId,
      required this.isFirst,
      required this.otherTracks});

  final Track track;
  final String playlistId;
  final bool isFirst;
  final List<Track> otherTracks;

  @override
  State<TrackListItem> createState() => _TrackListItemState();
}

class _TrackListItemState extends State<TrackListItem> {
  String subtitle = "";

  @override
  void initState() {
    subtitle = widget.track.artists.join(", ");
    if (widget.track.beforeThis != null) {
      subtitle += "\n\nPlays after ${widget.track.beforeThis!.name}";
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget trackWidget = GestureDetector(
        onTap: () async {
          String? otherTrackId = await showDialog<String?>(
              context: context,
              builder: (BuildContext context) {
                String? selectedId;

                List<DropdownMenuEntry<String>> dropdownItems = widget
                    .otherTracks
                    .map<DropdownMenuEntry<String>>((t) =>
                        DropdownMenuEntry<String>(value: t.id, label: t.name))
                    .toList();
                // Add "None" option
                dropdownItems.insert(
                    0, const DropdownMenuEntry(value: "None", label: "None"));

                DropdownMenu<String> menu = DropdownMenu(
                  dropdownMenuEntries: dropdownItems,
                  menuHeight: MediaQuery.sizeOf(context).height / 3,
                  onSelected: (value) {
                    selectedId = value;
                  },
                  initialSelection: widget.track.beforeThis?.id ?? "None",
                );

                return AlertDialog(
                  title: const Text("Edit Constraint"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text("Play ${widget.track.name} after:"), menu],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop<String?>(context, null),
                        child: const Text("Cancel")),
                    TextButton(
                        onPressed: () =>
                            Navigator.pop<String?>(context, selectedId),
                        child: const Text("OK"))
                  ],
                );
              });
          if (otherTrackId != null && otherTrackId != "None") {
            Track otherTrack = widget.otherTracks
                .singleWhere((element) => element.id == otherTrackId);

            widget.track.beforeThis = otherTrack;
            otherTrack.afterThis = widget.track;
            await setConstraint(
                widget.playlistId, otherTrack.id, widget.track.id);
          } else if (otherTrackId == "None") {
            String? firstTrack = await removeConstraintSecond(
                widget.playlistId, widget.track.id);
            widget.track.beforeThis = null;
            if (firstTrack != null) {
              Track otherTrack = widget.otherTracks
                  .singleWhere((element) => element.id == firstTrack);
              otherTrack.afterThis = null;
            }
          }

          setState(() {
            subtitle = widget.track.artists.join(", ");
            if (widget.track.beforeThis != null) {
              subtitle += "\n\nPlays after ${widget.track.beforeThis!.name}";
            }
          });
        },
        child: ListTile(
            title: Text(widget.track.name),
            subtitle: Text(subtitle),
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.network(widget.track.albumArtUrl)),
            trailing: IconButton(
                onPressed: () {
                  launchUrl(Uri.parse(widget.track.spotifyUrl),
                      mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.open_in_new)),
            isThreeLine: widget.track.beforeThis != null));

    List<Widget> trackAndDivider =
        widget.isFirst ? [trackWidget] : [const Divider(), trackWidget];
    return Column(children: trackAndDivider);
  }
}
