import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

class AddEntryPage extends StatefulWidget {
  final Map<String, dynamic>? entry;

  const AddEntryPage({super.key, this.entry});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  File? _image;
  DateTime _selectedDate = DateTime.now();
  double? _latitude;
  double? _longitude;
  List<String> _tags = [];
  bool _saving = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: source, imageQuality: 80);
    if (img != null) setState(() => _image = File(img.path));
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
  final supabase = Supabase.instance.client;

  try {
    setState(() => _saving = true);

    // 🔹 Check if user is logged in
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception("User not logged in – please sign in again");
    }

    String? photoUrl;
    if (_image != null) {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

      try {
        // 🔹 Confirm bucket exists
        final bucket = supabase.storage.from('photos');
        final uploaded = await bucket.uploadBinary(
          fileName,
          await _image!.readAsBytes(),
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

        print("✅ Upload response: $uploaded");

        if (uploaded.isEmpty) throw Exception("Upload failed!");
        photoUrl = bucket.getPublicUrl(fileName);
      } catch (e, st) {
        print("❌ Upload error: $e");
        print("📌 Stacktrace: $st");
        rethrow;
      }
    }

    final data = {
      "user_id": userId,
      "title": _titleCtrl.text.trim(),
      "description": _descCtrl.text.trim(),
      "photo_url": photoUrl != null ? [photoUrl] : [],
      "tags": _tags,
      "latitude": _latitude,
      "longitude": _longitude,
      "created_at": _selectedDate.toIso8601String(),
    };

    if (widget.entry == null) {
      await supabase.from('entries').insert(data);
    } else {
      await supabase.from('entries').update(data).eq('id', widget.entry!['id']);
    }

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Entry saved successfully!")),
      );
    }
  } catch (e) {
    if (mounted) {
      print("❌ Save error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  } finally {
    if (mounted) setState(() => _saving = false);
  }
}

  @override
  void initState() {
    super.initState();
    _fetchLocation();

    if (widget.entry != null) {
      _titleCtrl.text = widget.entry!['title'] ?? "";
      _descCtrl.text = widget.entry!['description'] ?? "";
      _selectedDate =
          DateTime.tryParse(widget.entry!['created_at'] ?? "") ??
          DateTime.now();
      _latitude = widget.entry!['latitude'];
      _longitude = widget.entry!['longitude'];
      final t = widget.entry!['tags'] ?? "";
      _tags = t
          .toString()
          .split(",")
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
  title: Text(
    widget.entry == null ? "New Journey" : "Edit Journey",
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.white,
    ),
  ),
  elevation: 6,
  backgroundColor: Colors.transparent,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      color: Colors.black, // pure black background
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(24), // rounded bottom
      ),
    ),
  ),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(24),
    ),
  ),
),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           // Title Card
Card(
  elevation: 6,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: TextField(
      controller: _titleCtrl,
      decoration: const InputDecoration(
        labelText: "Title",
        border: InputBorder.none, // removes the box
      ),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  ),
),
const SizedBox(height: 16),

// Description Card
Card(
  elevation: 6,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: TextField(
      controller: _descCtrl,
      maxLines: 5,
      decoration: const InputDecoration(
        labelText: "Description",
        border: InputBorder.none, // removes the box
      ),
    ),
  ),
),

            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat.yMMMd().format(_selectedDate)),
              trailing: TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: const Text("Change"),
              ),
            ),
            const SizedBox(height: 16),
           Row(
  children: [
    Expanded(
      child: ElevatedButton.icon(
        onPressed: () => _pickImage(ImageSource.camera),
        icon: const Icon(Icons.camera_alt),
        label: const Text("Camera"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: ElevatedButton.icon(
        onPressed: () => _pickImage(ImageSource.gallery),
        icon: const Icon(Icons.photo),
        label: const Text("Gallery"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
    ),
  ],
),

            if (_image != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, height: 180, fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 16),
            if (_latitude != null && _longitude != null)
              Text("📍 Location: $_latitude , $_longitude"),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: _saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _saving
                      ? "Saving..."
                      : widget.entry == null
                      ? "Save Entry"
                      : "Update Entry",
                ),
                onPressed: _saving ? null : _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
