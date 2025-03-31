import 'dart:async';
import 'package:collection/collection.dart';
import 'package:craft_launcher/craft_launcher.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mojang_api_repository/mojang_api_repository.dart';

class AuthState {
  final List<MinecraftAccount> accounts;
  final String? selectedAccount;

  const AuthState({
    this.accounts = const [],
    this.selectedAccount,
  });

  AuthState copyWith({
    List<MinecraftAccount>? accounts,
    String? selectedAccount,
  }) {
    return AuthState(
      accounts: accounts ?? this.accounts,
      selectedAccount: selectedAccount ?? this.selectedAccount,
    );
  }

  MinecraftAccount? getAccountById(String id) =>
      accounts.firstWhereOrNull((account) => account.uuid == id);
}

class AuthCubit extends HydratedCubit<AuthState> {
  final AuthRepository authRepo;

  AuthCubit({required this.authRepo}) : super(const AuthState());

  Future<void> startAuth() async {
    try {
      await authRepo.startAuth();
    } catch (error) {
      BeaverLog.error('Authentication error: $error');
    }
  }

  Future<void> finishAuth({
    required Uri uri,
  }) async {
    final MinecraftAccount authenticatedAccount =
        await authRepo.handleAuthCallback(uri: uri);

    // Check if an account with the same access token already exists
    final existingAccount = state.accounts.firstWhereOrNull(
      (account) => account.profile?.id == authenticatedAccount.profile?.id,
    );

    if (existingAccount != null) {
      return;
    }

    final updatedAccountsList = [...state.accounts, authenticatedAccount];

    emit(state.copyWith(
      accounts: updatedAccountsList,
      selectedAccount: authenticatedAccount.uuid,
    ));
  }

  Future<void> removeAccount(String accountId) async {
    final MinecraftAccount? account = state.getAccountById(accountId);
    if (account == null) return;

    final updatedAccounts = List<MinecraftAccount>.from(state.accounts)
      ..removeWhere((a) => a.uuid == accountId);

    String? newSelectedId = state.selectedAccount;
    if (state.selectedAccount == accountId) {
      newSelectedId =
          updatedAccounts.isNotEmpty ? updatedAccounts.first.uuid : null;
    }

    emit(state.copyWith(
      accounts: updatedAccounts,
      selectedAccount: newSelectedId,
    ));
  }

  void setActiveAccount(String accountId) {
    final MinecraftAccount? account = state.getAccountById(accountId);
    if (account == null) return;

    emit(state.copyWith(
      selectedAccount: accountId,
    ));
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic> accountsJson =
          (json['accounts'] as List<dynamic>?) ?? [];
      final List<MinecraftAccount> accounts = accountsJson
          .map((accountJson) =>
              MinecraftAccount.fromJson(accountJson as Map<String, dynamic>))
          .toList();

      // Simply get the selectedAccount UUID as a string
      final String? selectedAccountId = json['selectedAccount'] as String?;

      return AuthState(
        accounts: accounts,
        selectedAccount: selectedAccountId,
      );
    } catch (e) {
      BeaverLog.error('Error deserializing AuthState: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    try {
      return {
        'accounts': state.accounts.map((account) => account.toJson()).toList(),
        'selectedAccount': state.selectedAccount,
      };
    } catch (e) {
      BeaverLog.error('Error serializing AuthState: $e');
      return null;
    }
  }
}
