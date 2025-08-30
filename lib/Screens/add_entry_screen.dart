import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AddEntryPage extends StatefulWidget {
  const AddEntryPage({super.key, required entry, required int index});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<File> _images = [];
  DateTime _selectedDate = DateTime.now();
  double? _latitude;
  double? _longitude;
  List<String> _tags = [];
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null && _images.length < 5) {
      setState(() => _images.add(File(img.path)));
    }
  }

  Future<void> _fetchLocation() async {
    final location = Location();
    final hasPermission = await location.requestPermission();
    if (hasPermission == PermissionStatus.granted) {
      final pos = await location.getLocation();
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
      });
    }
  }

  Future<void> _saveEntry() async {
    setState(() => _loading = true);
    final supabase = Supabase.instance.client;

    List<String> photoUrls = [];
    for (var img in _images) {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      await supabase.storage.from('photos').upload(fileName, img);
      final url = supabase.storage.from('photos').getPublicUrl(fileName);
      photoUrls.add(url);
    }

    if (photoUrls.isNotEmpty) {
      final res = await http.post(
        Uri.parse("https://api.imagerecognition.com/tag"),
        body: jsonEncode({"url": photoUrls.first}),
      );
      if (res.statusCode == 200) {
        _tags = List<String>.from(jsonDecode(res.body)["tags"]);
      }
    }

    await supabase.from('entries').insert({
      "title": _titleCtrl.text,
      "description": _descCtrl.text,
      "photo_urls": photoUrls,
      "tags": _tags,
      "latitude": _latitude,
      "longitude": _longitude,
      "created_at": _selectedDate.toIso8601String(),
    });

    if (mounted) Navigator.pop(context);
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for clarity
      appBar: AppBar(
        title: const Text("Add Journal Entry",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  _buildCard(
                    child: TextField(
                      controller: _titleCtrl,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: "Title",
                        labelStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  _buildCard(
                    child: TextField(
                      controller: _descCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: "Description",
                        labelStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image Picker Button
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo, color: Colors.black),
                        label: const Text(
                          "Pick Photo",
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _saveEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(150, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save Entry",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Image Preview
                  if (_images.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: _images
                          .map(
                            (img) => Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    img,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => setState(() => _images.remove(img)),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 16),

                  // Date Selection
                  _buildCard(
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat.yMMMd().format(_selectedDate),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: const Text(
                            "Change Date",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location Info
                  if (_latitude != null)
                    _buildCard(
                      child: Text(
                        "📍 Location: $_latitude, $_longitude",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Tags Display
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: _tags
                          .map(
                            (t) => Chip(
                              label: Text(t),
                              backgroundColor: Colors.blue,
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
    );
  }

  // Reusable card container
  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
