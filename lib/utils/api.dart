import 'dart:convert';

import 'package:http/http.dart';
import 'package:shuffle_enforcer/models/playlist.dart';
import 'package:shuffle_enforcer/utils/auth.dart';

Future<Response?> callApiGet(Uri uri, [Map<String, String>? headers]) async {
  bool tokenStatus = await refreshTokensIfNeeded();
  if (!tokenStatus) {
    return null;
  }

  final String accessToken = await getAccessToken();
  Map<String, String> realHeaders = headers ?? <String, String>{};
  realHeaders["Authorization"] = "Bearer $accessToken";

  return await get(uri, headers: realHeaders);
}

Future<List<Playlist>> getPlaylistListing() async {
  bool hasNext = true;
  int currentOffset = 0;
  const int pageSize = 20;
  List<Playlist> playlists = [];

  while (hasNext) {
    Response? res = await callApiGet(Uri.https(
        "api.spotify.com",
        "/v1/me/playlists",
        {"limit": pageSize.toString(), "offset": currentOffset.toString()}));

    if (res == null) {
      print("error refreshing token");
      return [];
    }

    if (res.statusCode != 200) {
      print("error response");
      print(res.body);
      return [];
    }

    Map body = jsonDecode(res.body);
    for (Map playlist in body["items"]) {
      String? imageUrl;
      if ((playlist["images"] as List).isNotEmpty) {
        imageUrl = playlist["images"][0]["url"];
      }
      playlists.add(Playlist(
          playlist["id"],
          playlist["name"],
          playlist["description"],
          playlist["owner"]["display_name"],
          playlist["href"],
          imageUrl));
    }

    currentOffset += pageSize;
    hasNext = body["next"] != null;
  }

  return playlists;
}
