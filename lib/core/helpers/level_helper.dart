const List<String> allLevels = ["A1", "A2", "B1", "B2", "C1", "C2"];

bool isUnlocked(String level, String userLevel) {
  final userIndex = allLevels.indexOf(userLevel);
  final levelIndex = allLevels.indexOf(level);
  return levelIndex <= userIndex;
}
