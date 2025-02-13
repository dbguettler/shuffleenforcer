import 'package:flutter/material.dart';
import 'package:shuffle_enforcer/authorize.dart';
import 'package:shuffle_enforcer/playlist_listing.dart';
import 'package:shuffle_enforcer/utils/auth.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Future<bool> authed = tokensExist();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: FutureBuilder(
          future: authed,
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData && snapshot.data!) {
              return const PlaylistListing();
            } else if (snapshot.hasData) {
              return const Authorize();
            } else if (snapshot.hasError) {
              return const Text("An error has occurred.");
            } else {
              return const CircularProgressIndicator();
            }
          }),
    ));
  }
}
