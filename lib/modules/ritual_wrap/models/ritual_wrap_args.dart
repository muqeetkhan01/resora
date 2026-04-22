class RitualWrapFeature {
  const RitualWrapFeature._();

  static const journal = 'journal';
  static const meditation = 'meditation';
  static const asmr = 'asmr';
  static const visualization = 'visualization';
  static const normal = 'normal';
  static const talk = 'talk';
}

class RitualWrapPhase {
  const RitualWrapPhase._();

  static const entry = 'entry';
  static const exit = 'exit';
}

class RitualWrapArgs {
  const RitualWrapArgs({
    required this.feature,
    required this.phase,
    this.nextRoute,
    this.nextArguments,
  });

  final String feature;
  final String phase;
  final String? nextRoute;
  final dynamic nextArguments;

  bool get isEntry => phase == RitualWrapPhase.entry;

  factory RitualWrapArgs.entry({
    required String feature,
    required String nextRoute,
    dynamic nextArguments,
  }) {
    return RitualWrapArgs(
      feature: feature,
      phase: RitualWrapPhase.entry,
      nextRoute: nextRoute,
      nextArguments: nextArguments,
    );
  }

  factory RitualWrapArgs.exit({
    required String feature,
  }) {
    return RitualWrapArgs(
      feature: feature,
      phase: RitualWrapPhase.exit,
    );
  }

  factory RitualWrapArgs.from(dynamic value) {
    if (value is RitualWrapArgs) {
      return value;
    }

    if (value is Map) {
      return RitualWrapArgs(
        feature: value['feature'] as String? ?? RitualWrapFeature.journal,
        phase: value['phase'] as String? ?? RitualWrapPhase.entry,
        nextRoute: value['nextRoute'] as String?,
        nextArguments: value['nextArguments'],
      );
    }

    return const RitualWrapArgs(
      feature: RitualWrapFeature.journal,
      phase: RitualWrapPhase.entry,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'feature': feature,
      'phase': phase,
      'nextRoute': nextRoute,
      'nextArguments': nextArguments,
    };
  }
}
