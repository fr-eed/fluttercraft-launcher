import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth_cubit.dart';
import 'package:protocol_handler/protocol_handler.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with ProtocolListener {
  @override
  void initState() {
    protocolHandler.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    protocolHandler.removeListener(this);
    super.dispose();
  }

  @override
  void onProtocolUrlReceived(String url) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().handleAuthCallback(url);
    });
    print('Auth callback received: $url');
  }

  final List<Map<String, String>> accounts = [
    {'microsoftEmail': 'example@outlook.com', 'minecraftUsername': 'Player123'},
    {'microsoftEmail': 'test@hotmail.com', 'minecraftUsername': 'Minecrafter'},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Microsoft Accounts'),
        ),
        body: ListView.builder(
          itemCount: state.accounts.length,
          itemBuilder: (context, index) {
            final account = state.accounts[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color.fromARGB(0, 0, 0, 0),
                  backgroundImage: NetworkImage(
                      'https://crafatar.com/renders/head/${account.uuid}'),
                ),
                title: Text(account.username),
                subtitle: Text(account.username),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    context.read<AuthCubit>().removeAccount(account);
                  },
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.read<AuthCubit>().startAuth();
          },
          child: Icon(Icons.add),
        ),
      );
    });
  }
}
