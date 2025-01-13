import 'package:fluttcraft_launcher/constants.dart';
import 'package:flutter/material.dart';

class PlayScreen extends StatelessWidget {
  final ColorImageProvider imageSelected;

  const PlayScreen({super.key, required this.imageSelected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomScrollView(
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
                    image: AssetImage(imageSelected.path),
                    fit: BoxFit.fitWidth,
                    isAntiAlias: false,
                  ),
                ),
              ),
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
      ),
    );
  }
}
