import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mojang_api_repository/mojang_api_repository.dart';
import 'package:protocol_handler/protocol_handler.dart';
import '../cubits/auth_cubit.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with ProtocolListener {
  PersistentBottomSheetController? _bottomSheetController;

  @override
  void initState() {
    protocolHandler.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    protocolHandler.removeListener(this);
    _closeBottomSheet();
    super.dispose();
  }

  @override
  void onProtocolUrlReceived(String url) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AuthCubit>().finishAuth(
            uri: Uri.parse(url),
          );
    });

    print('Auth callback received: $url');
    _closeBottomSheet();
  }

  void _closeBottomSheet() {
    if (_bottomSheetController != null) {
      _bottomSheetController!.close();
      _bottomSheetController = null;
    }
  }

  void _showAuthBottomSheet() {
    _bottomSheetController = showBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 160,
          padding: EdgeInsets.all(20),
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Waiting for authentication...',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Cancel authentication
                  _closeBottomSheet();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Authentication cancelled')),
                  );
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Scaffold(
        body: state.accounts.isEmpty
            ? Center(
                child: Text('No accounts found, please add an account.',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))
            : ListView.builder(
                itemCount: state.accounts.length,
                itemBuilder: (context, index) {
                  final account = state.accounts[index];

                  if (state.accounts.isEmpty) {
                    return Text('No accounts found');
                  }

                  return AccountCard(
                    activeAccountUuid: state.selectedAccount!,
                    account: account,
                    onSetActiveAccount: (uuid) {
                      context.read<AuthCubit>().setActiveAccount(uuid);
                    },
                    onDelete: (account) {
                      context.read<AuthCubit>().removeAccount(account.uuid);
                    },
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _showAuthBottomSheet();
            await context.read<AuthCubit>().startAuth();
          },
          child: Icon(Icons.add),
        ),
      );
    });
  }
}

class AccountCard extends StatelessWidget {
  final String activeAccountUuid;
  final MinecraftAccount account;
  final void Function(String) onSetActiveAccount;
  final void Function(MinecraftAccount) onDelete;

  const AccountCard({
    super.key,
    required this.activeAccountUuid,
    required this.account,
    required this.onSetActiveAccount,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: ListTile(
        leading: account.authStatus == AuthStatus.initial
            ? CircularProgressIndicator()
            : CircleAvatar(
                backgroundColor: Color.fromARGB(0, 0, 0, 0),
                backgroundImage: NetworkImage(
                    'https://crafatar.com/renders/head/${account.profile?.id}'),
              ),
        title: Text(account.profile?.name ?? ''),
        subtitle: Text(account.profile?.id ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: Text('Set Active'),
              onPressed: account.uuid == activeAccountUuid
                  ? null
                  : () {
                      onSetActiveAccount(account.uuid);
                    },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                onDelete(account);
              },
            ),
          ],
        ),
      ),
    );
  }
}
