import 'package:mojang_api_repository/mojang_api_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
// import 'dart:io';

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

class AuthCubit extends HydratedCubit<AuthState> {
  final AuthRepository authRepo;

  AuthCubit({required this.authRepo})
      : super(const AuthState(status: AuthStatus.initial));

  Future<void> startAuth() async {
    emit(state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    ));

    try {
      await authRepo.startAuth();
      // We don't emit a new state here because we're waiting for the callback
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to start authentication: $e',
      ));
    }
  }

  void finishAuth(List<MinecraftAccount> accounts) {
    if (accounts.isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No accounts were found after authentication.',
      ));
      return;
    }

    // Merge new accounts with existing ones, avoiding duplicates
    final existingAccountIds = state.accounts.map((a) => a.profile.id).toSet();
    final uniqueNewAccounts = accounts
        .where((a) => !existingAccountIds.contains(a.profile.id))
        .toList();
    final mergedAccounts = [...state.accounts, ...uniqueNewAccounts];

    // Select the first account if none is selected
    final selectedAccount = state.selectedAccount ?? accounts.first;

    emit(state.copyWith(
      status: AuthStatus.authenticated,
      accounts: mergedAccounts,
      selectedAccount: selectedAccount,
      errorMessage: null,
    ));
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

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      final List<dynamic> accountsJson =
          (json['accounts'] as List<dynamic>?) ?? [];
      final List<MinecraftAccount> accounts = accountsJson
          .map((accountJson) =>
              MinecraftAccount.fromJson(accountJson as Map<String, dynamic>))
          .toList();

      MinecraftAccount? selectedAccount;
      if (json['selectedAccount'] != null) {
        selectedAccount = MinecraftAccount.fromJson(
            json['selectedAccount'] as Map<String, dynamic>);
      }

      return AuthState(
        status: AuthStatus.values[(json['status'] as int?) ?? 0],
        accounts: accounts,
        selectedAccount: selectedAccount,
        errorMessage: json['errorMessage'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    try {
      return {
        'status': state.status.index,
        'accounts': state.accounts.map((account) => account.toJson()).toList(),
        'selectedAccount': state.selectedAccount?.toJson(),
        'errorMessage': state.errorMessage,
      };
    } catch (e) {
      return null;
    }
  }
}
