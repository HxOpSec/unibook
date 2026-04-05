import 'package:flutter/material.dart';
import 'package:unibook/core/constants/tgfeu_data.dart';
import 'package:unibook/widgets/university_emblem.dart';

class AboutDialogContent extends StatelessWidget {
  const AboutDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TgfeuLogo(size: 52, textSize: 12),
        SizedBox(height: 12),
        Text('Версия 1.0.0'),
        SizedBox(height: 4),
        Text('Официальное приложение ТГФЭУ'),
        SizedBox(height: 4),
        Text('tgfeu.tj'),
        SizedBox(height: 4),
        Text(tgfeuAddress, textAlign: TextAlign.center),
      ],
    );
  }
}
