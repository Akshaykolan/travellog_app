import 'package:flutter_riverpod/flutter_riverpod.dart';

class Entry {
  final String id;
  final String title;
  final String description;
  final String dateTime;
  final String? address;
  final List<String> photos;
  final List<String> tags;

  Entry({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.address,
    this.photos = const [],
    this.tags = const [],
  });

  Entry copyWith({
    String? title,
    String? description,
    String? dateTime,
    String? address,
    List<String>? photos,
    List<String>? tags,
  }) {
    return Entry(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      address: address ?? this.address,
      photos: photos ?? this.photos,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime,
      'address': address,
      'photos': photos,
      'tags': tags,
    };
  }
}

class EntriesNotifier extends StateNotifier<List<Entry>> {
  EntriesNotifier() : super([]);

  void addEntry(Entry entry) {
    state = [...state, entry];
  }

  void updateEntry(String id, Entry updated) {
    state = [
      for (final entry in state)
        if (entry.id == id) updated else entry,
    ];
  }

  void deleteEntry(String id) {
    state = state.where((entry) => entry.id != id).toList();
  }
}

final entriesProvider =
    StateNotifierProvider<EntriesNotifier, List<Entry>>((ref) {
  return EntriesNotifier();
});
