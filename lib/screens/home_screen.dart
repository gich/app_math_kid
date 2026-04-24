import 'package:flutter/material.dart';

import '../logic/player_storage.dart';
import '../models/game_mode.dart';
import '../widgets/player_picker_dialog.dart';
import 'digit_picker_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _playerStorage = PlayerStorage();
  String _playerName = PlayerStorage.defaultName;

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    final name = await _playerStorage.getCurrent();
    if (!mounted) return;
    setState(() => _playerName = name);
  }

  Future<void> _openPicker(BuildContext context, GameMode mode) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DigitPickerScreen(mode: mode)),
    );
  }

  Future<void> _changePlayer() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => PlayerPickerDialog(currentName: _playerName),
    );
    if (result == null) return; // cancelled
    await _playerStorage.setCurrent(result);
    if (!mounted) return;
    setState(() => _playerName =
        result.trim().isEmpty ? PlayerStorage.defaultName : result.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplication Trainer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PlayerChip(name: _playerName, onTap: _changePlayer),
            const SizedBox(height: 48),
            _ModeButton(
              label: 'Training',
              icon: Icons.school,
              onPressed: () => _openPicker(context, GameMode.training),
            ),
            const SizedBox(height: 24),
            _ModeButton(
              label: 'Time Test',
              icon: Icons.timer,
              onPressed: () => _openPicker(context, GameMode.timeTest),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerChip extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _PlayerChip({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: const Icon(Icons.person, size: 20),
      label: Text(name, style: const TextStyle(fontSize: 16)),
      onPressed: onTap,
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 80,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 32),
        label: Text(label, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
