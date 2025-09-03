import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_entry_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> entries = [];
  bool _loading = false;

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    final res = await Supabase.instance.client
        .from('entries')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      entries = List<Map<String, dynamic>>.from(res);
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "My Travel Journal",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 4,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : RefreshIndicator(
              onRefresh: _loadEntries,
              child: entries.isEmpty
                  ? const Center(child: Text("No entries yet ✈️"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: entries.length,
                      itemBuilder: (context, i) {
                        final e = entries[i];

                        // Handle photo_url
                        String? photoUrl;
                        if (e['photo_url'] != null) {
                          if (e['photo_url'] is List && e['photo_url'].isNotEmpty) {
                            photoUrl = e['photo_url'][0];
                          } else if (e['photo_url'] is String && e['photo_url'].isNotEmpty) {
                            photoUrl = e['photo_url'];
                          }
                        }

                        // Handle tags
                        final tags = (e['tags'] ?? [])
                            .toString()
                            .split(',')
                            .where((t) => t.trim().isNotEmpty)
                            .toList();

                        return GestureDetector(
                          onLongPress: () {
                            // Show edit/delete bottom sheet
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              builder: (_) => SafeArea(
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: const Text('Edit'),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddEntryPage(entry: e),
                                          ),
                                        );
                                        if (updated == true) _loadEntries();
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete, color: Colors.red),
                                      title: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text("Delete Entry"),
                                            content: const Text(
                                              "Are you sure you want to delete this entry?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text(
                                                  "Delete",
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await Supabase.instance.client
                                              .from('entries')
                                              .delete()
                                              .eq('id', e['id']);
                                          _loadEntries();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (photoUrl != null)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      photoUrl,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e['title'] ?? "",
                                        style: const TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        e['description'] ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        children: tags.map((t) => Chip(label: Text(t))).toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "📅 ${e['created_at'] ?? ''}",
                                        style: const TextStyle(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEntryPage()),
          );
          if (added == true) Future.microtask(() => _loadEntries());
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
