// Три возможных состояния времени: до начала, первый час и завершение.
sealed class Countdown {
  const Countdown();
}

// промежуток времени, например 15 минут
final class Upcoming extends Countdown {
  const Upcoming(this.remaining);

  final Duration remaining;
  // мероприятие впереди; remaining хранит время до начала.
}

final class Started extends Countdown {
  const Started(this.elapsed);

  final Duration elapsed;
  // мероприятие началось; elapsed хранит время с начала.
}

final class Ended extends Countdown {
  const Ended();
  // мероприятие завершилось
}
