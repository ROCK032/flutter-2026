import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/students_views.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _api = FakeApi();
  List<Student>? _students;
  Object? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });

    try {
      final students = await _api.fetchStudents();
      if (!mounted) return;

      setState(() => _students = students);
    } catch (error) {
      if (!mounted) return;

      setState(() => _error = error);
    }
  }

  void _reload() {
    if (_saving || (_students == null && _error == null)) return;
    unawaited(_load());
  }

  Future<void> _save(BuildContext context) async {
    final students = _students;
    final route = ModalRoute.of(context);
    if (students == null || _saving || route?.isCurrent != true) return;

    setState(() => _saving = true);

    try {
      await _api.save(students.length);
      if (!context.mounted || route?.isCurrent != true) return;

      Navigator.of(context).pop();
    } on StateError catch (error) {
      if (!context.mounted || route?.isCurrent != true) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = _students;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          IconButton(
            onPressed: _students == null || _saving ? null : _reload,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: students == null
          ? null
          : FloatingActionButton(
              tooltip: 'Save',
              onPressed: _saving
                  ? null
                  : () async {
                      await _save(context);
                    },
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
            ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final students = _students;

    if (_error != null) return ErrorView(onRetry: _reload);
    if (students == null) return const LoadingView();
    if (students.isEmpty) return const EmptyView();

    return StudentList(students: students);
  }
}
