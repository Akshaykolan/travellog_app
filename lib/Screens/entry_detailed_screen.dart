import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travellog_app/provider/entry_provider.dart';
import 'package:travellog_app/screens/add_entry_screen.dart'; // Import AddEntryPage
import 'package:travellog_app/models/entry_model.dart'; // Import Entry model

class EntryDetailScreen extends ConsumerWidget {
  final String entryId;

  const EntryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(entriesProvider).firstWhere((e) => e.id == entryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEntryPage(entry: entry),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(entry.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(entry.description),
            const SizedBox(height: 16),
            Text('Tags: ${entry.tags.join(', ')}'),
            const SizedBox(height: 16),
            Image.network(entry.photos.isNotEmpty ? entry.photos[0] : 'placeholder_image_url'),
          ],
        ),
      ),
    );
  }
}
