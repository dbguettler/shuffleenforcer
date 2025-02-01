import 'package:flutter/material.dart';
import 'package:shuffle_enforcer/main.dart';
import 'package:shuffle_enforcer/utils/auth.dart';

class AuthCallback extends StatelessWidget {
  const AuthCallback({super.key, required this.params});

  final Map<String, String> params;

  void getTokens() async {
    bool success = await requestTokens(params["state"], params["code"]);
    if (success) {
      router.replace("/");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget childWidget = const Column(
        children: [CircularProgressIndicator(), Text("Loading auth...")]);
    if (params.containsKey("error") || !params.containsKey("code")) {
      childWidget = Text("Error: ${params["error"]}");
    } else {
      getTokens();
    }

    return Scaffold(body: Center(child: childWidget));
  }
}
