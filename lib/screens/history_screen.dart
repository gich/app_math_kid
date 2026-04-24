import 'package:flutter/material.dart';

import '../logic/results_storage.dart';
import '../models/game_mode.dart';
import '../models/quiz_result.dart';
import '../widgets/star_rating.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = ResultsStorage();
  List<QuizResult>? _results;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _storage.loadAll();
    if (!mounted) return;
    final timeTestOnly =
        items.where((r) => r.mode == GameMode.timeTest).toList();
    // Fastest first. Any entry without an elapsed time (legacy data) goes last.
    timeTestOnly.sort((a, b) {
      final ae = a.elapsed;
      final be = b.elapsed;
      if (ae == null && be == null) return 0;
      if (ae == null) return 1;
      if (be == null) return -1;
      return ae.compareTo(be);
    });
    setState(() => _results = timeTestOnly);
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text('All saved results will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _storage.clear();
    if (!mounted) return;
    setState(() => _results = []);
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final hasItems = results != null && results.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Reset progress',
            onPressed: hasItems ? _confirmReset : null,
          ),
        ],
      ),
      body: results == null
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
              ? const Center(
                  child: Text(
                    'No history yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ResultTile(result: results[i]),
                ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final QuizResult result;

  const _ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final digitsLabel = result.digits.map((d) => '×$d').join(', ');

    return Card(
      child: ListTile(
        leading: StarRating(filled: result.stars, size: 20),
        title: Text('${result.playerName} · $digitsLabel'),
        subtitle: Text(_subtitle()),
        trailing: Text(
          '${result.correct}/${result.total}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _subtitle() {
    final d = result.completedAt;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final elapsed = result.elapsed;
    if (elapsed != null) {
      return '$dateStr · ${elapsed.inSeconds}s';
    }
    return dateStr;
  }
}
