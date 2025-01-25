import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../auth/microsoft_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _minecraftProfileUrl =
    'https://api.minecraftservices.com/minecraft/profile';

class MinecraftAccount {
  final String username;
  final String uuid;
  final String accessToken;
  final DateTime tokenExpiry;

  MinecraftAccount({
    required this.username,
    required this.uuid,
    required this.accessToken,
    required this.tokenExpiry,
  });

  bool get isTokenValid => DateTime.now().isBefore(tokenExpiry);
}

class MinecraftProfile {
  final String username;
  final String uuid;

  MinecraftProfile({required this.username, required this.uuid});

  factory MinecraftProfile.fromJson(Map<String, dynamic> json) {
    return MinecraftProfile(
      username: json['name'] as String,
      uuid: json['id'] as String,
    );
  }
}

enum AuthStatus { initial, authenticating, authenticated, error }

class AuthState {
  final AuthStatus status;
  final List<MinecraftAccount> accounts;
  final MinecraftAccount? selectedAccount;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.accounts = const [],
    this.selectedAccount,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    List<MinecraftAccount>? accounts,
    MinecraftAccount? selectedAccount,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  final mca = MinecraftAuth();

  Future<void> startAuth() async {
    emit(state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    ));

    try {
      await mca.startAuth();
      // We don't emit a new state here because we're waiting for the callback
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to start authentication: $e',
      ));
    }
  }

  Future<void> handleAuthCallback(String url) async {
    if (state.status != AuthStatus.authenticating) {
      return; // Ignore callbacks if we're not expecting them
    }

    try {
      final Uri uri = Uri.parse(url);
      if (uri.scheme == 'fluttercraft' && uri.host == 'auth') {
        final String token = await mca.handleAuthCallback(uri);

        // Get user profile info using the token
        final accountInfo = await _fetchMinecraftProfile(token);

        final newAccount = MinecraftAccount(
          username: accountInfo.username,
          uuid: accountInfo.uuid,
          accessToken: token,
          tokenExpiry: DateTime.now().add(const Duration(hours: 24)),
        );

        final updatedAccounts = List<MinecraftAccount>.from(state.accounts)
          ..add(newAccount);

        emit(state.copyWith(
          status: AuthStatus.authenticated,
          accounts: updatedAccounts,
          selectedAccount: newAccount,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Authentication failed: $e',
      ));
    }
  }

  Future<MinecraftProfile> _fetchMinecraftProfile(String accessToken) async {
    final response = await http.get(
      Uri.parse(_minecraftProfileUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch Minecraft profile: ${response.statusCode}');
    }

    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;

    return MinecraftProfile.fromJson(data);
  }

  void selectAccount(MinecraftAccount account) {
    emit(state.copyWith(selectedAccount: account));
  }

  Future<void> removeAccount(MinecraftAccount account) async {
    final updatedAccounts = List<MinecraftAccount>.from(state.accounts)
      ..remove(account);

    MinecraftAccount? newSelected = state.selectedAccount;
    if (state.selectedAccount == account) {
      newSelected = updatedAccounts.isNotEmpty ? updatedAccounts.first : null;
    }

    emit(state.copyWith(
      accounts: updatedAccounts,
      selectedAccount: newSelected,
    ));
  }
}
