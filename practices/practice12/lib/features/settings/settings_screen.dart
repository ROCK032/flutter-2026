import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _signingOut = false;
  Future<void> _signOut() async {
    if (_signingOut) return;

    final auth = context.read<AuthModel>();
    setState(() => _signingOut = true);

    try {
      await auth.logout();
    } catch (_) {
      if (!mounted) return;

      setState(() => _signingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-out failed. Please try again.')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context)
        .popUntil((route) => route.isFirst); // закрывает экраны поверх первого
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>();
    final selectedCity = settings.city;

    final cities = <String>{
      ?selectedCity,
      for (final user in users.items)
        if (user.address.city.isNotEmpty) user.address.city,
    }.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: (value) async {
              await settings.setDark(value);
            },
          ),
          DropdownButtonFormField<String>(
            initialValue: selectedCity ?? '',
            decoration: const InputDecoration(labelText: 'City filter'),
            items: [
              const DropdownMenuItem(value: '', child: Text('All cities')),
              for (final city in cities)
                DropdownMenuItem(value: city, child: Text(city)),
            ],
            onChanged: (value) async {
              await settings.setCity(value == '' ? null : value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(_signingOut ? 'Signing out…' : 'Sign out'),
            onTap: _signingOut ? null : _signOut,
          ),
        ],
      ),
    );
  }
}
