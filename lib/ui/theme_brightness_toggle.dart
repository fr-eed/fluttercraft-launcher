import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/settings_cubit.dart';

class BrightnessButton extends StatelessWidget {
  const BrightnessButton({
    this.showTooltipBelow = true,
  });

  final bool showTooltipBelow;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Tooltip(
          preferBelow: showTooltipBelow,
          message: 'Toggle brightness',
          child: IconButton(
            // dark = dark icon because inconsistency with auto brightness
            icon: state.brightnessMode == BrightnessMode.dark
                ? const Icon(Icons.dark_mode_outlined)
                : state.brightnessMode == BrightnessMode.light
                    ? const Icon(Icons.light_mode_outlined)
                    : const Icon(Icons.brightness_auto_outlined),
            onPressed: () =>
                context.read<SettingsCubit>().cycleBrightnessModes(),
          ),
        );
      },
    );
  }
}
