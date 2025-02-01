import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shuffle_enforcer/auth_callback.dart';
import 'package:shuffle_enforcer/home.dart';

void main() {
  runApp(MaterialApp.router(routerConfig: router));
}

final router = GoRouter(routes: [
  GoRoute(path: "/", builder: (context, state) => const Home(), routes: [
    GoRoute(
        path: "authcallback",
        builder: (context, state) =>
            AuthCallback(params: state.uri.queryParameters))
  ])
]);
