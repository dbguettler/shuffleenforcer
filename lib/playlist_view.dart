import 'package:flutter/material.dart';
import 'package:shuffle_enforcer/models/playlist.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: Center(child: Text(playlist.name))));
  }
}
