import 'package:flutter/material.dart';
import 'package:shuffle_enforcer/utils/auth.dart';

class Authorize extends StatelessWidget {
  const Authorize({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Click to connect to Spotify.',
          ),
          FilledButton(onPressed: requestAuthorization, child: Text("Connect"))
        ],
      ),
    ));
  }
}
