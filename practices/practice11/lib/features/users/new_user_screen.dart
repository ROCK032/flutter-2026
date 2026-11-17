import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _formKey.currentState?.validate() != true) return;

    final model = context.read<UsersModel>();
    final draft = User(
      id: 0,
      name: _name.text.trim(),
      username: _username.text.trim(),
      email: _email.text.trim(),
      phone: '',
      address: const Address(
        street: '',
        suite: '',
        city: '',
        zipcode: '',
        geo: Geo(lat: 0, lng: 0),
      ),
      company: (name: '', catchPhrase: ''),
      companyBs: '',
    );

    setState(() => _saving = true);

    try {
      // Запускаем сохранение и ждём ответа сервера.
      // При успехе модель добавит пользователя в список.
      await model.createUser(draft);

      // Если форма уже удалена или больше не на переднем плане,
      // завершаем _save(), чтобы не закрыть другой экран.
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;

      // Сохранение прошло успешно. Закрываем форму.
      Navigator.of(context).pop();
    } on ApiException {
      // Сюда попадём, если сохранение завершилось ошибкой API.
      // Показываем сообщение только пока форма открыта и видна.
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save user. Please try again.')),
      );
    } finally {
      // Этот блок выполняется и при успехе, и при ошибке, и при раннем return.
      // Если форма ещё существует, выключаем индикатор и включаем Save.
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Enter a name' : null,
            ),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Enter a username' : null,
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final email = (value ?? '').trim();
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
                    ? null
                    : 'Enter a valid email';
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
