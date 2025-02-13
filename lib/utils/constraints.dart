import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuffle_enforcer/models/constraint.dart';

Future<List<Constraint>> getConstraints(String playlistId) async {
  final prefs = SharedPreferencesAsync();
  String key = "playlist::$playlistId";
  bool hasConstraints = await prefs.containsKey(key);

  if (!hasConstraints) {
    return [];
  }

  List<String> constraintStrings = (await prefs.getStringList(key))!;
  List<Constraint> constraints = [];

  for (String constraintString in constraintStrings) {
    List<String> trackIds = constraintString.split(",");
    constraints.add(Constraint(trackIds[0], trackIds[1]));
  }

  return constraints;
}

Future<void> setConstraints(
    String playlistId, List<Constraint> constraints) async {
  final prefs = SharedPreferencesAsync();
  String key = "playlist::$playlistId";

  List<String> strConstraints = [];
  for (Constraint c in constraints) {
    strConstraints.add("${c.firstId},${c.secondId}");
  }

  await prefs.setStringList(key, strConstraints);

  return;
}

Future<void> setConstraint(
    String playlistId, String firstTrackId, String secondTrackId) async {
  final prefs = SharedPreferencesAsync();
  String key = "playlist::$playlistId";
  List<String> strConstraints = (await prefs.getStringList(key))!;
  List<String> newConstraints = [];

  for (String c in strConstraints) {
    List<String> trackIds = c.split(",");
    if (trackIds[0] != firstTrackId && trackIds[1] != secondTrackId) {
      newConstraints.add(c);
    }
  }

  newConstraints.add("$firstTrackId,$secondTrackId");

  await prefs.setStringList(key, newConstraints);
  return;
}

Future<String?> removeConstraintSecond(
    String playlistId, String secondTrackId) async {
  final prefs = SharedPreferencesAsync();
  String key = "playlist::$playlistId";
  List<String> strConstraints = (await prefs.getStringList(key))!;
  List<String> newConstraints = [];

  String? firstTrackId;

  for (String c in strConstraints) {
    List<String> trackIds = c.split(",");
    if (trackIds[1] != secondTrackId) {
      newConstraints.add(c);
    } else {
      firstTrackId = trackIds[0];
    }
  }

  await prefs.setStringList(key, newConstraints);
  return firstTrackId;
}
