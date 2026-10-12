const _meses = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String formatPeriod(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  return '${date.year}-$month';
}

String formatMonthYear(DateTime date) {
  return '${_meses[date.month - 1]} de ${date.year}';
}

String formatCurrency(int centavos) {
  final sign = centavos < 0 ? '-' : '';
  final absolute = centavos.abs();
  final reais = (absolute ~/ 100).toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  final cents = (absolute % 100).toString().padLeft(2, '0');
  return '$sign'
      'R\$ $reais,$cents';
}

String formatApiDate(DateTime date) {
  return date.toIso8601String().substring(0, 10);
}
