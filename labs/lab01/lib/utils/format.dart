// Форматирует дату и время без сторонних пакетов.
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

// Месяцы индексируются с нуля, поэтому используем month - 1.
String formatDate(DateTime value) {
  return '${value.day} ${_months[value.month - 1]}';
}

// padLeft добавляет ноль: 9:5 превращается в 09:05.
String formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

// Объединяет готовые дату и время.
String formatDateTime(DateTime value) {
  return '${formatDate(value)}, ${formatTime(value)}';
}
