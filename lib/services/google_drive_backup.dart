import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class GoogleDriveBackupService {
  GoogleDriveBackupService._();
  static final GoogleDriveBackupService instance = GoogleDriveBackupService._();

  static const String _scope = 'https://www.googleapis.com/auth/drive.appdata';
  static const String _fileName = 'wapari_backup.json';
  static const String _serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
  static const List<String> _scopes = <String>[_scope];

  bool _initialized = false;
  GoogleSignInAccount? _account;

  Future<Map<String, String>> _authorizedHeaders() async {
    final signIn = GoogleSignIn.instance;
    if (!_initialized) {
      await signIn.initialize(
        serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
      );
      _initialized = true;
    }

    GoogleSignInAccount? account = _account;
    if (account == null) {
      if (signIn.supportsAuthenticate()) {
        account = await signIn.authenticate();
      } else {
        throw Exception('اس Android ورژن میں Google Sign-In دستیاب نہیں۔');
      }
      _account = account;
    }

    GoogleSignInClientAuthorization? authorization =
        await account.authorizationClient.authorizationForScopes(_scopes);
    authorization ??= await account.authorizationClient.authorizeScopes(_scopes);
    return <String, String>{
      'Authorization': 'Bearer ${authorization.accessToken}',
      'Content-Type': 'application/json; charset=utf-8',
    };
  }

  Future<String> uploadBackup() async {
    final headers = await _authorizedHeaders();
    final raw = jsonEncode(await LocalStore.exportBackup());
    final listUri = Uri.https('www.googleapis.com', '/drive/v3/files', {
      'spaces': 'appDataFolder',
      'q': "name='$_fileName' and trashed=false",
      'fields': 'files(id,name)',
      'pageSize': '10',
    });
    final listed = await http.get(listUri, headers: headers);
    _check(listed);
    final files = (jsonDecode(listed.body) as Map<String, dynamic>)['files'] as List<dynamic>? ?? [];
    if (files.isEmpty) {
      final created = await http.post(
        Uri.https('www.googleapis.com', '/drive/v3/files', {'fields': 'id'}),
        headers: headers,
        body: jsonEncode({'name': _fileName, 'mimeType': 'application/json', 'parents': ['appDataFolder']}),
      );
      _check(created);
      final id = (jsonDecode(created.body) as Map<String, dynamic>)['id'] as String;
      final uploaded = await http.patch(
        Uri.https('www.googleapis.com', '/upload/drive/v3/files/$id', {'uploadType': 'media'}),
        headers: {...headers, 'Content-Type': 'application/json; charset=utf-8'},
        body: raw,
      );
      _check(uploaded);
      return id;
    }
    final id = (files.first as Map<String, dynamic>)['id'] as String;
    final updated = await http.patch(
      Uri.https('www.googleapis.com', '/upload/drive/v3/files/$id', {'uploadType': 'media'}),
      headers: {...headers, 'Content-Type': 'application/json; charset=utf-8'},
      body: raw,
    );
    _check(updated);
    return id;
  }

  Future<String?> downloadBackup() async {
    final headers = await _authorizedHeaders();
    final listed = await http.get(
      Uri.https('www.googleapis.com', '/drive/v3/files', {
        'spaces': 'appDataFolder',
        'q': "name='$_fileName' and trashed=false",
        'fields': 'files(id,name)',
        'pageSize': '10',
      }),
      headers: headers,
    );
    _check(listed);
    final files = (jsonDecode(listed.body) as Map<String, dynamic>)['files'] as List<dynamic>? ?? [];
    if (files.isEmpty) return null;
    final id = (files.first as Map<String, dynamic>)['id'] as String;
    final response = await http.get(
      Uri.https('www.googleapis.com', '/drive/v3/files/$id', {'alt': 'media'}),
      headers: headers,
    );
    _check(response);
    return response.body;
  }

  void _check(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Google اجازت یا Drive API فعال نہیں۔ Google Cloud Console میں Drive API اور Android OAuth Client (Package + SHA-1) سیٹ کریں۔');
    }
    throw Exception('Google Drive HTTP ${response.statusCode}: ${response.body}');
  }
}
