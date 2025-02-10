import "package:hydrated_bloc/hydrated_bloc.dart";

enum InstanceType {
  release,
  snapshot,
  imported;

  // name
  String get name {
    switch (this) {
      case InstanceType.release:
        return 'Official Release';
      case InstanceType.snapshot:
        return 'Snapshot';
      case InstanceType.imported:
        return 'Imported';
    }
  }
}

class CraftInstanceModel {
  final String id;
  final String name;

  final InstanceType type;
  final String version;

  const CraftInstanceModel(
      {required this.id,
      required this.name,
      required this.version,
      this.type = InstanceType.release});

  factory CraftInstanceModel.fromJson(Map<String, dynamic> json) {
    return CraftInstanceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      type: InstanceType.values.byName(json['type'] as String? ?? 'release'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'version': version, 'type': type.name};
  }
}

class CraftInstanceCubit extends HydratedCubit<CraftInstanceState> {
  CraftInstanceCubit() : super(const CraftInstanceState()) {
    // if no instances, create 1 sample
    if (state.instances.isEmpty) {
      addNewInstance(
          CraftInstanceModel(id: '1', name: 'Minecraft', version: '1.19.2'));

      selectInstance('1');
    }
  }

  void selectInstance(String id) {
    emit(state.copyWith(selectedInstanceId: id));
  }

  void addNewInstance(CraftInstanceModel instance) {
    final updatedInstances = List<CraftInstanceModel>.from(state.instances)
      ..add(instance);
    emit(state.copyWith(instances: updatedInstances));
  }

  void removeInstanceById(String id) {
    final updatedInstances = List<CraftInstanceModel>.from(state.instances)
      ..removeWhere((element) => element.id == id);
    emit(state.copyWith(instances: updatedInstances));
  }

  void updateInstanceById(String id, CraftInstanceModel updatedInstance) {
    final updatedInstances = List<CraftInstanceModel>.from(state.instances)
      ..removeWhere((element) => element.id == id)
      ..add(updatedInstance);
    emit(state.copyWith(instances: updatedInstances));
  }

  @override
  CraftInstanceState? fromJson(Map<String, dynamic> json) {
    return CraftInstanceState(
      instances: (json['instances'] as List<dynamic>?)
              ?.map(
                  (e) => CraftInstanceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      selectedInstanceId: json['selectedInstanceId'] as String?,
    );
  }

  @override
  Map<String, dynamic>? toJson(CraftInstanceState state) {
    return {
      'instances': state.instances.map((e) => e.toJson()).toList(),
      'selectedInstanceId': state.selectedInstanceId,
    };
  }
}

class CraftInstanceState {
  final List<CraftInstanceModel> instances;
  final String? selectedInstanceId;

  // getter
  CraftInstanceModel? get selectedInstance {
    if (selectedInstanceId == null) {
      return null;
    }
    for (var instance in instances) {
      if (instance.id == selectedInstanceId) {
        return instance;
      }
    }
    return null;
  }

  const CraftInstanceState({
    this.instances = const [],
    this.selectedInstanceId,
  });

  CraftInstanceState copyWith({
    List<CraftInstanceModel>? instances,
    String? selectedInstanceId,
  }) {
    return CraftInstanceState(
      instances: instances ?? this.instances,
      selectedInstanceId: selectedInstanceId ?? this.selectedInstanceId,
    );
  }
}
