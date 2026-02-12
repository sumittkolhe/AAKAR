class ScenarioQuestion {
  final String id;
  final String scenario;
  final String emotion;
  final List<String> options;
  final String explanation;

  ScenarioQuestion({
    required this.id,
    required this.scenario,
    required this.emotion,
    required this.options,
    required this.explanation,
  });
}
