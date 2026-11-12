import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/students_views.dart';

class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key});

  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  final _api = FakeApi();

  // Retry заменяет завершившийся запрос новым.
  late Future<List<Student>> _future;
  bool _compact = false;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchStudents();
  }

  void _retry() {
    setState(() {
      _future = _api.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('FutureBuilder'),
      actions: [
        Switch(
          value: _compact,
          onChanged: (value) => setState(() => _compact = value),
        ),
      ],
    ),
    body: FutureBuilder<List<Student>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError &&
            snapshot.connectionState == ConnectionState.done) {
          return ErrorView(onRetry: _retry);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        final students = snapshot.data ?? const <Student>[];
        if (students.isEmpty) return const EmptyView();

        return StudentList(students: students, compact: _compact);
      },
    ),
  );
}
