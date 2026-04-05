import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

class DdmitLogo extends StatelessWidget {
  const DdmitLogo({
    super.key,
    this.size = 64,
    this.text = 'ДДМИТ',
    this.textSize = 14,
  });

  final double size;
  final String text;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.45),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: textSize,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
