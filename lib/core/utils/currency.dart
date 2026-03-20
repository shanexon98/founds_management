String formatCop(int amount) {
  final s = amount.toString();
  final reg = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
  final formatted = s.replaceAllMapped(reg, (m) => '${m[1]}.');
  return '\$$formatted';
}
