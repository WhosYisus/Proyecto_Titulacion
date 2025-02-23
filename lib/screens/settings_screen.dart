import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              ListTile(
                title: const Text('Text Size'),
                subtitle: Slider(
                  value: settings.fontSize,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  label: settings.fontSize.round().toString(),
                  onChanged: (value) => settings.setFontSize(value),
                ),
              ),
              ListTile(
                title: const Text('Font Family'),
                trailing: DropdownButton<String>(
                  value: settings.fontFamily,
                  items: const [
                    DropdownMenuItem(value: 'Poppins', child: Text('Poppins')),
                    DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                    DropdownMenuItem(value: 'OpenSans', child: Text('Open Sans')),
                  ],
                  onChanged: (value) => settings.setFontFamily(value!),
                ),
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: settings.isDarkMode,
                onChanged: (value) => settings.setDarkMode(value),
              ),
            ],
          );
        },
      ),
    );
  }
}

