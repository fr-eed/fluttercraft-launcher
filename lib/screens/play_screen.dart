import 'package:fluttcraft_launcher/constants.dart';
import 'package:fluttcraft_launcher/cubits/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayScreen extends StatelessWidget {
  final ColorImageProvider imageSelected;

  PlayScreen({super.key, required this.imageSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
      return CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      image: DecorationImage(
                        image: AssetImage(
                          context.read<SettingsCubit>().state.selectedImagePath,
                        ),
                        fit: BoxFit.fitWidth,
                        isAntiAlias: false,
                      ))),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {},
                  label: const Text('Launch'),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
