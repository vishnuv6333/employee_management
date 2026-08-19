import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  final List<Color> _themeColors = const [
    Colors.deepPurple,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'Appearance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between light and dark themes'),
                value: state.isDarkMode,
                onChanged: (val) {
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
                secondary: Icon(
                  state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Theme Color',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: _themeColors.map((color) {
                  // ignore: deprecated_member_use
                  final isSelected = state.seedColor.value == color.value;
                  return GestureDetector(
                    onTap: () {
                      context.read<ThemeBloc>().add(ChangeThemeColor(color));
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Advanced',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.integration_instructions),
                title: const Text('Native Integrations Demo'),
                subtitle: const Text(
                  'Test Method Channels (Device Info, Date Picker, etc.)',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/native-demo');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
