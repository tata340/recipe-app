import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class AddRecipeScreen extends StatefulWidget {
  final String userId;

  const AddRecipeScreen({super.key, required this.userId});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedTags = [];
  Uint8List? _imageBytes;
  bool _isLoading = false;

  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submitRecipe() async {
    if (!_formKey.currentState!.validate() || _imageBytes == null) return;

    setState(() {
      _isLoading = true;
    });

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final imageUrl = await _storageService.uploadRecipeImage(
      fileName: fileName,
      fileBytes: _imageBytes!,
    );

    await _firestoreService.addRecipe(
      title: _titleController.text,
      description: _descriptionController.text,
      imageUrl: imageUrl,
      tags: _selectedTags,
      userId: widget.userId,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Vegan', 'Dessert', 'Quick', 'Healthy', 'Dinner']
                    .map((tag) => FilterChip(
                          label: Text(tag),
                          selected: _selectedTags.contains(tag),
                          onSelected: (selected) {
                            setState(() {
                              selected ? _selectedTags.add(tag) : _selectedTags.remove(tag);
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              _imageBytes != null
                  ? Image.memory(_imageBytes!, height: 200)
                  : TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pick Image'),
                    ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRecipe,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
