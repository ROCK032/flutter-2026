import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _prefs = SharedPreferencesAsync();
  Uint8List? _avatar;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadAvatar());
  }

  Future<void> _loadAvatar() async {
    Uint8List? bytes;
    try {
      final path = await _prefs.getString('avatarPath') ?? '';
      if (path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) bytes = await file.readAsBytes();
      }
    } catch (_) {
      // Keep the default avatar if the saved photo cannot be loaded.
    } finally {
      if (mounted) {
        setState(() {
          _avatar = bytes;
          _busy = false;
        });
      }
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      if (source == ImageSource.camera && !await _requestCamera()) return;
      if (!mounted) return;

      final photo = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (photo == null || !mounted) return;

      final directory = await getApplicationDocumentsDirectory();
      final saved = await File(photo.path)
          .copy('${directory.path}${Platform.pathSeparator}avatar.jpg');
      final bytes = await saved.readAsBytes();
      await _prefs.setString('avatarPath', saved.path);

      if (mounted) setState(() => _avatar = bytes);
    } catch (_) {
      if (mounted) _showMessage('Could not choose or save the photo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _requestCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return false;

    switch (status) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.denied:
        _showMessage('Allow camera access to take a profile photo.');
        return false;
      case PermissionStatus.permanentlyDenied:
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Camera access blocked'),
            content: const Text('Allow camera access in app settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Open settings'),
              ),
            ],
          ),
        );
        if (openSettings == true && mounted) {
          final opened = await openAppSettings();
          if (!opened && mounted) _showMessage('Could not open app settings.');
        }
        return false;
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        _showMessage('Camera access is unavailable.');
        return false;
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _avatar;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage: avatar == null ? null : MemoryImage(avatar),
              child: avatar == null ? const Text('P') : null,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _busy
                ? null
                : () async => _pickPhoto(ImageSource.gallery),
            child: const Text('Choose photo'),
          ),
          FilledButton(
            onPressed: _busy
                ? null
                : () async => _pickPhoto(ImageSource.camera),
            child: const Text('Take photo'),
          ),
        ],
      ),
    );
  }
}
