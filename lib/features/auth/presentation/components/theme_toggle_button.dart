import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../../../core/theme/theme_event.dart';

class ThemeToggleButton extends StatelessWidget {
  final Color backgroundColor;

  const ThemeToggleButton({super.key, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: isDark ? Colors.amber : Colors.indigo,
        ),
        onPressed: () {
          context.read<ThemeBloc>().add(ToggleThemeEvent());
        },
      ),
    );
  }
}
