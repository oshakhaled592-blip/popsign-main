List levels = ["A1", "A2", "B1", "B2", "C1"];

bool isUnlocked(String level, String userLevel) {
  int userIndex = levels.indexOf(userLevel);
  int levelIndex = levels.indexOf(level);

  return levelIndex <= userIndex;
}