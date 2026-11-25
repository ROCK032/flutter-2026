import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'user_detail_screen.dart';
import '../../core/api/api_exception.dart';
import 'users_model.dart';
import '../settings/settings_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final city = context.watch<SettingsModel>().city;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'New user',
            icon: const Icon(Icons.person_add),
            onPressed: model.loading
                ? null
                : () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const NewUserScreen(),
                      ),
                    );
                  },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (model.fromCache && model.error == null)
            MaterialBanner(
              leading: const Icon(Icons.cloud_off),
              content: const Text('Saved data · no connection'),
              actions: [
                TextButton(
                  onPressed: model.loading ? null : model.load,
                  child: const Text('Retry'),
                ),
              ],
            ),
          Expanded(child: _buildBody(model, city)),
        ],
      ),
    );
  }

  Widget _buildBody(UsersModel model, String? city) {
    final items = city == null
        ? model.items
        : model.items.where((user) => user.address.city == city).toList();
    if (model.loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = model.error;
    if (error != null) {
      return switch (error) {
        NoConnectionException() => _errorView(
          'No connection. Check your internet connection.',
          onRetry: model.load,
        ),
        ServerException(status: final status) => _errorView(
          'Server error ($status). Please try again.',
          onRetry: model.load,
        ),
        NotFoundException() => _errorView('Users not found.'),
        UnauthorizedException() => _errorView('Sign-in required.'),
        BadResponseException() => _errorView(
          'Unexpected response from the server.',
        ),
      };
    }
    if (model.items.isEmpty) {
      return const Center(child: Text('No users yet'));
    }
    return RefreshIndicator(
      // Жест обновления вызывает тот же load(), что и кнопка Retry.
      onRefresh: model.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = items[index];

          return ListTile(
            title: Text(user.name),
            subtitle: Text('${user.email}\n${user.address.city}'),
            isThreeLine: true,
            onTap: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => UserDetailScreen(user: user),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _errorView(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
