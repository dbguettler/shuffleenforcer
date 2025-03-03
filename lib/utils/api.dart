import 'dart:convert';

import 'package:http/http.dart';
import 'package:shuffle_enforcer/models/device.dart';
import 'package:shuffle_enforcer/models/playlist.dart';
import 'package:shuffle_enforcer/models/track.dart';
import 'package:shuffle_enforcer/utils/auth.dart';
import 'package:shuffle_enforcer/utils/constraints.dart';

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

Future<Response?> callApiPut(Uri uri, Map body,
    [Map<String, String>? headers]) async {
  bool tokenStatus = await refreshTokensIfNeeded();
  if (!tokenStatus) {
    return null;
  }

  final String accessToken = await getAccessToken();
  Map<String, String> realHeaders = headers ?? <String, String>{};
  realHeaders["Authorization"] = "Bearer $accessToken";
  realHeaders["Content-Type"] = "application/json";

  return await put(uri, body: jsonEncode(body), headers: realHeaders);
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
      throw Exception("Error refreshing token!");
    }

    if (res.statusCode != 200) {
      throw Exception("Error response!");
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
          playlist["external_urls"]["spotify"],
          imageUrl));
    }

    currentOffset += pageSize;
    hasNext = body["next"] != null;
  }

  return playlists;
}

Future<List<Track>> getPlaylistTracks(String id) async {
  Response? aboutUserResponse =
      await callApiGet(Uri.https("api.spotify.com", "/v1/me"));

  if (aboutUserResponse == null || aboutUserResponse.statusCode != 200) {
    throw Exception("Could not load user's country code.");
  }

  Map aboutUser = jsonDecode(aboutUserResponse.body);
  String countryCode = aboutUser["country"];

  bool hasNext = true;
  int currentOffset = 0;
  const int pageSize = 20;
  List<Track> tracks = [];

  while (hasNext) {
    Response? res = await callApiGet(
        Uri.https("api.spotify.com", "/v1/playlists/$id/tracks", {
      "market": countryCode,
      "fields":
          "next,items(is_local,track(album(images),artists(name),id,name,external_urls))",
      "limit": pageSize.toString(),
      "offset": currentOffset.toString()
    }));

    if (res == null) {
      throw Exception("Error refreshing tokens!");
    }

    if (res.statusCode != 200) {
      throw Exception("Error response fetching tracks!");
    }

    Map body = jsonDecode(res.body);
    for (Map item in body["items"]) {
      Map track = item["track"];

      if (item["is_local"]) {
        continue;
      }

      String albumArt = track["album"]["images"][0]["url"];
      List<String> artists = [];

      for (Map artist in track["artists"]) {
        artists.add(artist["name"]);
      }

      tracks.add(Track(track["id"], track["name"], artists, albumArt,
          track["external_urls"]["spotify"]));
    }

    currentOffset += pageSize;
    hasNext = body["next"] != null;
  }

  return tracks;
}

Future<bool> shuffleAndPlay(Playlist playlist, String deviceId) async {
  if (await hasLoopingConstraints(playlist)) {
    return false;
  }

  // Shuffle playlist and generate list of Spotify URIs
  List<Track> shuffled = (await playlist.getTracks())
      .where((track) => track.beforeThis == null)
      .toList();
  shuffled.shuffle();

  for (int i = 0; i < shuffled.length; i++) {
    if (shuffled[i].afterThis != null) {
      shuffled.insert(i + 1, shuffled[i].afterThis!);
    }
  }

  List<String> trackUris =
      shuffled.map((element) => "spotify:track:${element.id}").toList();

  Response? res = await callApiPut(
      Uri.https(
          "api.spotify.com", "/v1/me/player/play", {"device_id": deviceId}),
      {"uris": trackUris});

  if (res == null) {
    throw Exception("Error refreshing token!");
  }

  if (res.statusCode != 204) {
    throw Exception("Error response!");
  }

  return true;
}

Future<List<Device>> getDevices() async {
  Response? res =
      await callApiGet(Uri.https("api.spotify.com", "/v1/me/player/devices"));

  if (res == null) {
    throw Exception("Error refreshing token!");
  }

  if (res.statusCode != 200) {
    throw Exception("Error response!");
  }

  Map body = jsonDecode(res.body);
  List<Device> devices = [];

  for (Map device in body["devices"]) {
    if (!device["is_restricted"]) {
      devices.add(Device(device["id"], device["name"]));
    }
  }

  return devices;
}
