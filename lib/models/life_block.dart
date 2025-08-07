enum LifeBlock {
  health,
  career,
  family,
  finances,
  education,
  hobbies,
  spirituality,
  relationships,
}

String getBlockLabel(LifeBlock block) {
  switch (block) {
    case LifeBlock.health:
      return "Здоровье";
    case LifeBlock.career:
      return "Карьера";
    case LifeBlock.family:
      return "Семья";
    case LifeBlock.finances:
      return "Финансы";
    case LifeBlock.education:
      return "Образование";
    case LifeBlock.hobbies:
      return "Хобби";
    case LifeBlock.spirituality:
      return "Духовность";
    case LifeBlock.relationships:
      return "Отношения";
  }
}
