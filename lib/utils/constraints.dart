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
