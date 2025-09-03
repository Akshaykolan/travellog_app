import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travellog_app/provider/entry_provider.dart';
import 'package:travellog_app/screens/add_entry_screen.dart';
import 'package:travellog_app/models/entry_model.dart';

class EntryDetailScreen extends ConsumerWidget {
  final String entryId;

  const EntryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entriesProvider);
    final entry = entries.firstWhere(
      (e) => e.id == entryId,
      orElse: () => Entry(
        id: '',
        title: 'Entry not found',
        description: '',
        tags: [],
        photos: [], dateTime: '',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
        actions: entry.id.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (_) => AddEntryPage(entry: entry, index: entries.indexOf(entry)),
                    //   ),
                    // );
                    
                  },
                ),
              ]
            : null,
      ),
      body: entry.id.isEmpty
          ? const Center(child: Text('Entry not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text('Tags: ${entry.tags.join(', ')}'),
                  const SizedBox(height: 16),
                  entry.photos.isNotEmpty
                      ? Image.network(entry.photos[0])
                      : Image.asset('assets/images/placeholder.png'), // make sure this asset exists
                ],
              ),
            ),
    );
  }
}
