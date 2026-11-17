import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final address = user.address;

    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(title: const Text('ID'), subtitle: Text('${user.id}')),
          ListTile(
            title: const Text('Username'),
            subtitle: Text(user.username),
          ),
          ListTile(title: const Text('Email'), subtitle: Text(user.email)),
          ListTile(
            title: const Text('Phone'),
            subtitle: Text(user.phone),
            onTap: () {}, // Открытие номера добавим в Practice 12.
          ),
          ListTile(
            title: const Text('Website'),
            subtitle: Text(user.website ?? 'No website'),
            onTap: user.website == null ? null : () {},
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
        ],
      ),
    );
  }
}
