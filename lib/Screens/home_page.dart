import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/entry_model.dart';
import 'add_entry_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<EntryModel> entries = [];
  bool _loading = false;

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    final res = await Supabase.instance.client.from('entries').select();
    setState(() {
      entries = (res as List).map((e) => EntryModel.fromMap(e)).toList();
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "My Travel Journal",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24), // 👈 gives rounded bottom corners
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : RefreshIndicator(
              color: Colors.black,
              onRefresh: _loadEntries,
              child: entries.isEmpty
                  ? const Center(
                      child: Text(
                        "No entries yet ✈️",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: entries.length,
                      itemBuilder: (context, i) {
                        final e = entries[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              // Navigate to detail screen
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 📸 Image Section
                                if (e.photoUrl != null &&
                                    e.photoUrl!.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      e.photoUrl!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      color: Colors.black.withOpacity(0.05),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.photo,
                                        size: 60,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),

                                // 📝 Content Section
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        e.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: -8,
                                        children: e.tags
                                            .map(
                                              (t) => Chip(
                                                label: Text(t),
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.05),
                                                labelStyle: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "📅 ${e.createdAt.toLocal()}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black45,
                                        ),
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
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEntryPage(entry: null, index: 0),
            ),
          );
          _loadEntries();
        },
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
