import 'package:flutter/material.dart';

import '../logic/player_storage.dart';

/// A dialog to change the current player. Returns the new name through
/// [Navigator.pop] (may be an empty string = reset to default; null = cancel).
class PlayerPickerDialog extends StatefulWidget {
  final String currentName;

  const PlayerPickerDialog({super.key, required this.currentName});

  @override
  State<PlayerPickerDialog> createState() => _PlayerPickerDialogState();
}

class _PlayerPickerDialogState extends State<PlayerPickerDialog> {
  late final TextEditingController _controller;
  final _storage = PlayerStorage();
  List<String>? _known;

  @override
  void initState() {
    super.initState();
    final initial = widget.currentName == PlayerStorage.defaultName
        ? ''
        : widget.currentName;
    _controller = TextEditingController(text: initial);
    _loadKnown();
  }

  Future<void> _loadKnown() async {
    final names = await _storage.getKnown();
    if (!mounted) return;
    setState(() => _known = names);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Player name'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: PlayerStorage.maxNameLength,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Leave empty for "unknown"',
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (_known != null && _known!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Previously used:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _known!
                    .map((name) => ActionChip(
                          label: Text(name),
                          onPressed: () =>
                              setState(() => _controller.text = name),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
