import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

String generateCodeVerifier(int length) {
  const String allowedValues =
      "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789_.-~";
  Random randGen = Random();
  String output = "";
  for (int i = 0; i < length; i++) {
    output += allowedValues[randGen.nextInt(allowedValues.length)];
  }

  return output;
}

Digest hashSHA256(String code) {
  return sha256.convert(utf8.encode(code));
}

String encodeVerifier(String verifier) {
  return base64Encode(hashSHA256(verifier).bytes)
      .replaceAll("=", "")
      .replaceAll("+", "-")
      .replaceAll("/", "_");
}

void requestAuthorization() async {
  final prefs = SharedPreferencesAsync();

  // Generate verifier and hashed/encoded verifier
  String verifier = generateCodeVerifier(128);
  String encodedVerifier = encodeVerifier(verifier);

  // Create random state string (prevents CSRF)
  String state = generateCodeVerifier(128);

  // Save state and verifier to be used in callback
  await prefs.setString("csrf_state", state);
  await prefs.setString("verifier", verifier);

  // Launch auth page
  String redirectUri =
      Uri.https("shuffleenforcer.guettlerlabs.com", "/authcallback").toString();
  Uri authURL = Uri.https("accounts.spotify.com", "/authorize", {
    "response_type": "code",
    "client_id": "de6289eff46548bda83bff349504395f",
    "scope": "playlist-read-private user-modify-playback-state",
    "code_challenge_method": "S256",
    "code_challenge": encodedVerifier,
    "state": state,
    "redirect_uri": redirectUri
  });

  await launchUrl(authURL);
}

Future<bool> requestTokens(String? receivedState, String? receivedCode) async {
  // Read stored verifier and state
  final prefs = SharedPreferencesAsync();
  String? state = await prefs.getString("csrf_state");
  String? verifier = await prefs.getString("verifier");
  if (state == null || verifier == null) {
    print("state or verifier null");
    return false;
  }

  // Check that state received from the callback matches expected state
  if (state != receivedState) {
    print("state mismatch");
    return false;
  }

  // Request tokens using code from callback and stored verifier
  Response res =
      await post(Uri.https("accounts.spotify.com", "/api/token"), body: {
    "grant_type": "authorization_code",
    "code": receivedCode,
    "redirect_uri":
        Uri.https("shuffleenforcer.guettlerlabs.com", "/authcallback")
            .toString(),
    "client_id": "de6289eff46548bda83bff349504395f",
    "code_verifier": verifier
  }, headers: {
    "Content-Type": "application/x-www-form-urlencoded"
  });

  // Check that response was ok
  if (res.statusCode != 200) {
    print("error response");
    print(res.body);
    return false;
  }

  // Store access/refresh tokens and expiry time
  Map body = jsonDecode(res.body);
  await prefs.setString("access", body["access_token"]);
  await prefs.setString("refresh", body["refresh_token"]);
  await prefs.setInt("expiry",
      DateTime.now().millisecondsSinceEpoch * 1000 + body["expires_in"] as int);

  return true;
}

Future<bool> tokensExist() async {
  final prefs = SharedPreferencesAsync();
  bool tokensExist = true;
  List<String> keys = ["access", "refresh", "expiry"];
  for (String key in keys) {
    tokensExist &= await prefs.containsKey(key);
  }

  return tokensExist;
}
