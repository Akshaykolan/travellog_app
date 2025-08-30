import 'package:flutter/foundation.dart';

class EntryModel {
  final String id;
  final String title;
  final String description;
  final String? photoUrl;
  final String? address; // Added address field for consistency
  final List<String> tags;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  EntryModel({
    required this.id,
    required this.title,
    required this.description,
    this.photoUrl,
    this.address,
    required this.tags,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory EntryModel.fromMap(Map<String, dynamic> map) {
    return EntryModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      photoUrl: map['photo_url'] as String?,
      address: map['address'] as String?,
      tags: (map['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      createdAt: map['created_at'] is String
          ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
          : (map['created_at'] is DateTime ? map['created_at'] : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photo_url': photoUrl,
      'address': address,
      'tags': tags,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static empty() {}
}