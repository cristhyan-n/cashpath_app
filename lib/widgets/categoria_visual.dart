import 'package:flutter/material.dart';

class CategoriaVisual {
  const CategoriaVisual(this.icone, this.cor, this.fundo);

  final IconData icone;
  final Color cor;
  final Color fundo;

  static CategoriaVisual para(
    String nome, {
    String? grupo,
    bool receita = false,
  }) {
    if (receita || grupo == 'receita') {
      return const CategoriaVisual(
        Icons.account_balance_wallet_rounded,
        Color(0xFF2C8A62),
        Color(0xFFEAF4EB),
      );
    }

    final texto = _normalizar(nome);
    if (grupo == 'economia' ||
        _tem(texto, ['invest', 'reserva', 'poup', 'econom'])) {
      return const CategoriaVisual(
        Icons.savings_rounded,
        Color(0xFF2C8A62),
        Color(0xFFEAF4EB),
      );
    }
    if (_tem(texto, [
      'aliment',
      'mercado',
      'comida',
      'refeicao',
      'restaurante',
    ])) {
      return const CategoriaVisual(
        Icons.restaurant_rounded,
        Color(0xFFA47B28),
        Color(0xFFFAF2DE),
      );
    }
    if (_tem(texto, [
      'transport',
      'combust',
      'gasolina',
      'carro',
      'uber',
      'onibus',
    ])) {
      return const CategoriaVisual(
        Icons.directions_car_rounded,
        Color(0xFF477A62),
        Color(0xFFEAF2EC),
      );
    }
    if (_tem(texto, ['moradia', 'casa', 'aluguel', 'condominio'])) {
      return const CategoriaVisual(
        Icons.home_rounded,
        Color(0xFF5277A0),
        Color(0xFFEAF0F7),
      );
    }
    if (_tem(texto, ['saude', 'farmacia', 'medic', 'consulta'])) {
      return const CategoriaVisual(
        Icons.health_and_safety_rounded,
        Color(0xFFB65B5B),
        Color(0xFFF8EBE9),
      );
    }
    if (_tem(texto, ['educa', 'curso', 'escola', 'faculdade', 'livro'])) {
      return const CategoriaVisual(
        Icons.menu_book_rounded,
        Color(0xFF7965A6),
        Color(0xFFF0ECF7),
      );
    }
    if (_tem(texto, ['lazer', 'viagem', 'cinema', 'entreten'])) {
      return const CategoriaVisual(
        Icons.local_activity_rounded,
        Color(0xFFB46B45),
        Color(0xFFF8EEE8),
      );
    }
    if (_tem(texto, [
      'conta',
      'internet',
      'agua',
      'luz',
      'energia',
      'telefone',
    ])) {
      return const CategoriaVisual(
        Icons.receipt_long_rounded,
        Color(0xFF537B91),
        Color(0xFFEAF1F4),
      );
    }
    if (_tem(texto, ['compra', 'roupa', 'pessoal'])) {
      return const CategoriaVisual(
        Icons.shopping_bag_rounded,
        Color(0xFFAD6684),
        Color(0xFFF7ECF1),
      );
    }
    if (grupo == 'desejo') {
      return const CategoriaVisual(
        Icons.favorite_rounded,
        Color(0xFFAD6684),
        Color(0xFFF7ECF1),
      );
    }
    return const CategoriaVisual(
      Icons.sell_rounded,
      Color(0xFF5F786A),
      Color(0xFFEDF2EE),
    );
  }

  static bool _tem(String texto, List<String> termos) =>
      termos.any(texto.contains);

  static String _normalizar(String texto) => texto
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('â', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ç', 'c');
}

class CategoriaIcone extends StatelessWidget {
  const CategoriaIcone({
    super.key,
    required this.nome,
    this.grupo,
    this.size = 38,
    this.receita = false,
  });

  final String nome;
  final String? grupo;
  final double size;
  final bool receita;

  @override
  Widget build(BuildContext context) {
    final visual = CategoriaVisual.para(nome, grupo: grupo, receita: receita);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: visual.fundo,
        borderRadius: BorderRadius.circular(size * .31),
      ),
      child: Icon(visual.icone, color: visual.cor, size: size * .5),
    );
  }
}
