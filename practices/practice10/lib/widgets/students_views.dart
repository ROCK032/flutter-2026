import 'package:flutter/material.dart';

import '../api/fake_api.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Loading students...'),
      ],
    ),
  );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Could not load students'),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('No students yet'));
}

class StudentList extends StatelessWidget {
  const StudentList({super.key, required this.students, this.compact = false});
  final List<Student> students;
  final bool compact;

  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: students.length,
    itemBuilder: (_, index) {
      final student = students[index];
      final gpa = student.gpa?.toString() ?? '-';

      return ListTile(
        title: Text(student.name),
        subtitle: Text(student.group),
        trailing: Text('GPA $gpa'),
        dense: compact,
      );
    },
  );
}
