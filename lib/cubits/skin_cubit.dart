import 'package:file_selector/file_selector.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mojang_api_repository/mojang_api_repository.dart';
import 'dart:io';

class SkinsState {}

class SkinsInitial extends SkinsState {}

class SkinsLoaded extends SkinsState {
  final List<Skin> skins;

  SkinsLoaded(this.skins);

  SkinsLoaded copyWith({
    List<Skin>? skins,
  }) {
    return SkinsLoaded(
      skins ?? this.skins,
    );
  }
}

class SkinCubit extends Cubit<SkinsState> {
  final PlayerCustomizationApi playerCustomizationApi;

  SkinCubit({required this.playerCustomizationApi}) : super(SkinsInitial());

  void changeSkin(String skinPath) {}

  Future<void> addSkin(XFile file) async {
    await playerCustomizationApi.writeSkinToDirectory(file);
  }

  Future<void> getSkins() async {
    final skins = await playerCustomizationApi.getSkinsFromDirectory();
    // emit(SkinsLoaded(skins));
  }
}
