import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Audio & Accessibility',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Play sounds on button taps'),
            value: settings.soundEffectsEnabled,
            onChanged: (_) => settings.toggleSoundEffects(),
            secondary: const Icon(Icons.volume_up),
          ),

          SwitchListTile(
            title: const Text('Text-to-Speech'),
            subtitle: const Text('Read results aloud'),
            value: settings.ttsEnabled,
            onChanged: (_) => settings.toggleTTS(),
            secondary: const Icon(Icons.record_voice_over),
          ),

          ListTile(
            title: const Text('TTS Speed'),
            subtitle: Slider(
              value: settings.ttsSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              label: '${settings.ttsSpeed.toStringAsFixed(1)}x',
              onChanged: (value) => settings.setTTSSpeed(value),
            ),
            leading: const Icon(Icons.speed),
          ),

          const Divider(height: 32),

          const Text(
            'Accessibility',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Color Blind Mode'),
            subtitle: const Text('Adjust colors for better visibility'),
            value: settings.colorBlindMode,
            onChanged: (_) => settings.toggleColorBlindMode(),
            secondary: const Icon(Icons.palette),
          ),

          const Divider(height: 32),

          const Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ListTile(
            title: const Text('About A.A.K.A.R'),
            subtitle: const Text('Learn more about the app'),
            leading: const Icon(Icons.info),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),

          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.app_settings_alt),
          ),
          
          const Divider(height: 32),
          
          ListTile(
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/role-selection', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
