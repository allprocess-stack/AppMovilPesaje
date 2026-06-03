import 'package:flutter/material.dart';

class ReusableFilaInfo extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const ReusableFilaInfo({
    super.key,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(child: Text(valor, maxLines: 1)),
        ],
      ),
    );
  }
}
