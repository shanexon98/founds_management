String formatDateTime(DateTime dt) {
  String two(int n) => n < 10 ? '0$n' : '$n';
  final d = two(dt.day);
  final m = two(dt.month);
  final y = dt.year;
  final h = two(dt.hour);
  final min = two(dt.minute);
  return '$d/$m/$y $h:$min';
}
