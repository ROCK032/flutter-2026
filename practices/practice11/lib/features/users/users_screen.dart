import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'new_user_screen.dart';
import 'user_detail_screen.dart';
import '../../core/api/api_exception.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
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
        ],
      ),
      body: _buildBody(model),
    );
  }

  Widget _buildBody(UsersModel model) {
    if (model.loading && model.items.isEmpty) {
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
      onRefresh: model.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: model.items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = model.items[index];

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
