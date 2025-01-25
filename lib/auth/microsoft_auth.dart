import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:protocol_handler/protocol_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../util/beaver.dart';

class MinecraftAuth {
  // Azure application credentials
  static const String clientId = '342fdc8c-8112-477b-9ea1-1bc1af5aef4e';
  static const String redirectUri = 'fluttercraft://auth';

  // Authentication endpoints
  static const String microsoftAuthUrl =
      'https://login.live.com/oauth20_authorize.srf';
  static const String microsoftTokenUrl =
      'https://login.live.com/oauth20_token.srf';
  static const String xboxAuthUrl =
      'https://user.auth.xboxlive.com/user/authenticate';
  static const String xstsAuthUrl =
      'https://xsts.auth.xboxlive.com/xsts/authorize';
  static const String mcAuthUrl =
      'https://api.minecraftservices.com/authentication/login_with_xbox';

  final _authCompleter = Completer<String>();
  Completer<String>? _activeAuthCompleter;

  // Handles initial OAuth callback from Microsoft
  Future<void> handleAuth(Uri uri) async {
    if (!_authCompleter.isCompleted &&
        uri.queryParameters.containsKey('code')) {
      _authCompleter.complete(uri.queryParameters['code']);
    }
  }

  // Initiates Microsoft OAuth flow
  Future<void> startAuth() async {
    _activeAuthCompleter?.completeError('New auth started');
    _activeAuthCompleter = Completer<String>();

    final Uri authUri = Uri.parse(microsoftAuthUrl).replace(queryParameters: {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'scope': 'XboxLive.signin XboxLive.offline_access',
      'prompt': 'select_account',
    });

    if (!await canLaunchUrl(authUri)) {
      throw Exception('Could not launch auth URL');
    }

    await launchUrl(authUri, mode: LaunchMode.externalApplication);
  }

  // Processes OAuth callback and completes full authentication chain
  Future<String> handleAuthCallback(Uri uri) async {
    if (_activeAuthCompleter == null) {
      throw StateError('No active authentication in progress');
    }

    try {
      if (!uri.queryParameters.containsKey('code')) {
        throw StateError('Invalid auth callback - no code present');
      }

      final code = uri.queryParameters['code']!;
      final String msAccessToken = await getMicrosoftToken(code);
      final Map<String, dynamic> xboxData =
          await getXboxLiveToken(msAccessToken);
      final Map<String, dynamic> xstsData =
          await getXSTSToken(xboxData['Token'] as String);

      final String minecraftToken = await getMinecraftToken(
          xstsData['Token'] as String,
          (xstsData['DisplayClaims']['xui'][0]['uhs'] as String));

      _activeAuthCompleter = null;
      return minecraftToken;
    } catch (e) {
      _activeAuthCompleter = null;
      rethrow;
    }
  }

  // Exchanges OAuth code for Microsoft access token
  Future<String> getMicrosoftToken(String code) async {
    final response = await http.post(
      Uri.parse(microsoftTokenUrl),
      body: {
        'client_id': clientId,
        'code': code,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
        'scope': 'XboxLive.signin offline_access',
      },
    );

    if (response.statusCode != 200) {
      throw StateError('Failed to get Microsoft token');
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    return data['access_token'] as String;
  }

  // Exchanges Microsoft token for Xbox Live token
  Future<Map<String, dynamic>> getXboxLiveToken(String msAccessToken) async {
    final response = await http.post(
      Uri.parse(xboxAuthUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'Properties': {
          'AuthMethod': 'RPS',
          'SiteName': 'user.auth.xboxlive.com',
          'RpsTicket': 'd=$msAccessToken'
        },
        'RelyingParty': 'http://auth.xboxlive.com',
        'TokenType': 'JWT'
      }),
    );

    if (response.statusCode != 200) {
      throw StateError('Failed to get Xbox Live token');
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  // Exchanges Xbox Live token for XSTS token
  Future<Map<String, dynamic>> getXSTSToken(String xblToken) async {
    final response = await http.post(
      Uri.parse(xstsAuthUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'Properties': {
          'SandboxId': 'RETAIL',
          'UserTokens': [xblToken]
        },
        'RelyingParty': 'rp://api.minecraftservices.com/',
        'TokenType': 'JWT'
      }),
    );

    if (response.statusCode != 200) {
      throw StateError('Failed to get XSTS token');
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  // Exchanges XSTS token for Minecraft access token
  Future<String> getMinecraftToken(String xstsToken, String userHash) async {
    final identityToken = 'XBL3.0 x=$userHash;$xstsToken'.trim();

    final response = await http.post(
      Uri.parse(mcAuthUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'identityToken': identityToken,
      }),
    );

    if (response.statusCode != 200) {
      throw StateError('Failed to get Minecraft token');
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    if (!data.containsKey('access_token')) {
      throw StateError('Invalid response structure');
    }

    return data['access_token'] as String;
  }
}
