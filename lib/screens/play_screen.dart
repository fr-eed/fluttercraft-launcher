import 'dart:ui';

import 'package:fluttercraft_launcher/cubits/instances_cubit.dart';
import 'package:fluttercraft_launcher/cubits/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../util/beaver.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  GameImage(),
                  SizedBox(height: 16),
                  GameInfoRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GameImage extends StatelessWidget {
  const GameImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                image: DecorationImage(
                  image: AssetImage(state.selectedImagePath),
                  fit: BoxFit.fitWidth,
                  isAntiAlias: false,
                ),
              ),
            );
          },
        ),
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.black.withOpacity(0.2),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: const GameInfoOverlay(),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () {
              // Handle launch
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please login to Microsoft Account first'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.fixed,
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Launch'),
          ),
        ),
      ],
    );
  }
}

class GameInfoOverlay extends StatelessWidget {
  const GameInfoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CraftInstanceCubit, CraftInstanceState>(
        builder: (context, state) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(
            onTap: () => _showVersionList(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withOpacity(0.4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.games,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.selectedInstance?.name ?? 'Select Instance',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        state.selectedInstance != null
                            ? "${state.selectedInstance?.type.name} ${state.selectedInstance?.version}"
                            : "",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showVersionList(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return BlocBuilder<CraftInstanceCubit, CraftInstanceState>(
            builder: (context, state) {
          return ListView(
              padding: const EdgeInsets.all(16.0),
              children: state.instances.map((instance) {
                return ListTile(
                  title: Text("${instance.name} ${instance.version}"),
                  trailing: instance == state.selectedInstance
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    context
                        .read<CraftInstanceCubit>()
                        .selectInstance(instance.id);
                    Navigator.pop(context);
                  },
                );
              }).toList());
        });
      },
    );
  }
}

class GameInfoRow extends StatelessWidget {
  const GameInfoRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
            child: InfoCard(
                icon: Icons.timer, title: 'Play Time', subtitle: '0h')),
        SizedBox(width: 8),
        Expanded(
            child: InfoCard(
                icon: Icons.folder,
                title: 'Open Folder',
                subtitle: 'Location')),
        SizedBox(width: 8),
        Expanded(
            child: InfoCard(
                icon: Icons.more_horiz, title: 'Coming Soon', subtitle: '')),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const InfoCard(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(subtitle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
