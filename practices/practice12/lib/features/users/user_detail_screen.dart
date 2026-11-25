import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/secure_store.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  // Список передаёт выбранный объект User целиком, и карточка читает его поля.
  final User user;
  Future<void> _openLink(BuildContext context, Uri uri) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      // The platform can report a failed launch as an exception.
    }

    if (opened || !context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('No app can open this')));
  }

  Uri? get _websiteUri {
    final website = user.website?.trim() ?? '';
    if (website.isEmpty) return null;

    final uri = Uri.tryParse(
      website.contains('://') ? website : 'https://$website',
    );
    if (uri == null ||
        uri.host.isEmpty ||
        (!uri.isScheme('https') && !uri.isScheme('http'))) {
      return null;
    }

    return uri.replace(scheme: 'https');
  }

  @override
  Widget build(BuildContext context) {
    final address = user.address;
    final websiteUri = _websiteUri;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(title: const Text('ID'), subtitle: Text('${user.id}')),
          ListTile(
            title: const Text('Username'),
            subtitle: Text(user.username),
          ),
          ListTile(
            title: const Text('Email'),
            subtitle: Text(user.email),
            onTap: () async {
              await _openLink(context, Uri(scheme: 'mailto', path: user.email));
            },
          ),
          ListTile(
            title: const Text('Phone'),
            subtitle: Text(user.phone),
            onTap: () async {
              await _openLink(
                context,
                Uri(scheme: 'tel', path: user.phoneDigits),
              );
            },
          ),
          ListTile(
            title: const Text('Website'),
            subtitle: Text(user.website ?? 'No website'),
            onTap: websiteUri == null
                ? null
                : () async {
                    await _openLink(context, websiteUri);
                  },
          ),
          ListTile(
            title: const Text('Address'),
            subtitle: Text(
              '${address.street}, ${address.suite}\n'
              '${address.city}, ${address.zipcode}',
            ),
            isThreeLine: true,
          ),
          ListTile(
            title: const Text('Coordinates'),
            subtitle: Text('${address.geo.lat}, ${address.geo.lng}'),
          ),
          ListTile(
            title: const Text('Company'),
            subtitle: Text('${user.company.name}\n${user.company.catchPhrase}'),
            isThreeLine: true,
          ),
          ListTile(
            title: const Text('Business'),
            subtitle: Text(user.companyBs),
          ),
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy token to clipboard'),
              onTap: () async {
                final token = await const SecureStore().readToken();
                if (token == null || !context.mounted) return;

                await Clipboard.setData(ClipboardData(text: token));
                if (!context.mounted) return;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Token copied')));
              },
            ),
        ],
      ),
    );
  }
}
