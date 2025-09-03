import 'package:flutter/foundation.dart';

class EntryModel {
  final String id;
  final String title;
  final String description;
  final List<String> photoUrls; // ✅ handles multiple photos
  final String? address;
  final List<String> tags;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  EntryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.photoUrls,
    this.address,
    required this.tags,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory EntryModel.fromMap(Map<String, dynamic> map) {
    return EntryModel(
      id: map['id'] as String,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      photoUrls: List<String>.from(map['photo_urls'] ?? []), // ✅ ARRAY
      address: map['address'] as String?,
      tags: List<String>.from(map['tags'] ?? []), // ✅ ARRAY
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      createdAt: map['created_at'] is String
          ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
          : (map['created_at'] is DateTime
              ? map['created_at']
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photo_urls': photoUrls, // ✅ save as array
      'address': address,
      'tags': tags,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// ✅ helper to preview first photo
  String? get photoUrl =>
      photoUrls.isNotEmpty ? photoUrls.first : null;

  /// ✅ static empty for new entry
  static EntryModel empty() {
    return EntryModel(
      id: '',
      title: '',
      description: '',
      photoUrls: [],
      address: null,
      tags: [],
      latitude: null,
      longitude: null,
      createdAt: DateTime.now(),
    );
  }
}
