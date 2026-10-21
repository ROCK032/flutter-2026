// Неизменяемый профиль студента: имя, группа и создание изменённой копии.
class Profile {
  const Profile({required this.name, required this.group});
  const Profile.empty() : name = '', group = ''; // именованный конструктор. Он создаёт пустой профиль, который понадобится при запуске приложения и сбросе данных.
  // Имя используется для записи на мероприятие; группа — для профиля.
  final String name;
  final String group;

  // Не меняет исходный профиль, а возвращает новую модель.
  Profile copyWith({
    // создаёт новый профиль с выбранными изменениями
    String? name,
    String? group,
  }) {
    return Profile(
      name: name ?? this.name,
      group: group ?? this.group,
    ); // используй переданное имя; если оно null, оставь имя текущего объекта
  }
}
