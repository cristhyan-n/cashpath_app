int? parseCentavos(String? text) {
  final valor = double.tryParse((text ?? '').trim().replaceAll(',', '.'));
  if (valor == null) return null;
  return (valor * 100).round();
}
