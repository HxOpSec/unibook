import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

/// A custom [AppBar] with the university purple gradient.
class UniAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UniAppBar({
    super.key,
    this.title,
    this.titleText,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.withGradient = false,
    this.bottom,
  });

  final Widget? title;
  final String? titleText;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool withGradient;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final resolvedTitle =
        title ?? (titleText != null ? Text(titleText!) : null);

    if (withGradient) {
      return AppBar(
        leading: leading,
        title: resolvedTitle,
        actions: actions,
        centerTitle: centerTitle,
        bottom: bottom,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: AppColors.white,
        elevation: 0,
      );
    }

    return AppBar(
      leading: leading,
      title: resolvedTitle,
      actions: actions,
      centerTitle: centerTitle,
      bottom: bottom,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}
