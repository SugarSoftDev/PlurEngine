import 'skill_action.dart';

abstract class Skill {
  Skill({
    required this.skillId,
    required this.name,
    required this.description,
    required this.action,
  });

  final String skillId;
  final String name;
  final String description;
  final SkillAction action;
}
