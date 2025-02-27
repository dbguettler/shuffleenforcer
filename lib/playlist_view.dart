import 'package:flutter/material.dart';
import 'package:shuffle_enforcer/models/device.dart';
import 'package:shuffle_enforcer/models/playlist.dart';
import 'package:shuffle_enforcer/models/track.dart';
import 'package:shuffle_enforcer/track_list_item.dart';
import 'package:shuffle_enforcer/utils/api.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView({
    super.key,
    required this.playlist,
  });

  final Playlist playlist;

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  List<Device> devices = [];
  String? selectedDevice;

  @override
  void initState() {
    getDevices().then((devs) => setState(() {
          devices = devs;
        }));
    super.initState();
  }

  void setSelectedDevice(String? deviceId) {
    setState(() {
      selectedDevice = deviceId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.playlist.name),
              centerTitle: true,
            ),
            bottomNavigationBar: BottomAppBar(
                child: DropdownMenu(
              label: const Text("Device"),
              dropdownMenuEntries: devices
                  .map((dev) =>
                      DropdownMenuEntry(value: dev.id, label: dev.name))
                  .toList(),
              initialSelection: selectedDevice,
              onSelected: (String? device) {
                setSelectedDevice(device);
              },
              width: MediaQuery.sizeOf(context).width * 0.6,
            )),
            floatingActionButton: FloatingActionButton(
                elevation: 0,
                backgroundColor: selectedDevice == null
                    ? const Color.fromARGB(255, 124, 124, 124)
                    : null,
                foregroundColor: selectedDevice == null
                    ? const Color.fromARGB(255, 58, 58, 58)
                    : null,
                onPressed: selectedDevice != null
                    ? () async {
                        await shuffleAndPlay(widget.playlist, selectedDevice!);
                      }
                    : null,
                child: const Icon(Icons.shuffle)),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endContained,
            body: FutureBuilder(
              future: widget.playlist.getTracks(),
              builder: (context, AsyncSnapshot<List<Track>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Track track = snapshot.data![index];

                        List<Track> otherTracks = [...snapshot.data!];
                        otherTracks.remove(track);

                        return TrackListItem(
                            track: track,
                            playlistId: widget.playlist.id,
                            isFirst: index == 0,
                            otherTracks: otherTracks);
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
