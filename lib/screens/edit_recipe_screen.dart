
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class EditRecipeScreen extends StatefulWidget {
  final String recipeId;
  final String currentTitle;
  final String currentDescription;
  final String currentImageUrl;
  final List<String> currentTags;

  const EditRecipeScreen({
    super.key,
    required this.recipeId,
    required this.currentTitle,
    required this.currentDescription,
    required this.currentImageUrl,
    required this.currentTags,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<String> _selectedTags;
  Uint8List? _newImageBytes;
  bool _isLoading = false;

  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentTitle);
    _descriptionController = TextEditingController(text: widget.currentDescription);
    _selectedTags = List.from(widget.currentTags);
  }

  Future<void> _pickNewImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _newImageBytes = bytes;
      });
    }
  }

  Future<void> _updateRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String imageUrl = widget.currentImageUrl;

    if (_newImageBytes != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      imageUrl = await _storageService.uploadRecipeImage(
        fileName: fileName,
        fileBytes: _newImageBytes!,
      );
    }

    await _firestoreService.updateRecipe(
      recipeId: widget.recipeId,
      title: _titleController.text,
      description: _descriptionController.text,
      imageUrl: imageUrl,
      tags: _selectedTags,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Recipe')),
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
              _newImageBytes != null
                  ? Image.memory(_newImageBytes!, height: 200)
                  : Image.network(widget.currentImageUrl, height: 200),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _pickNewImage,
                icon: const Icon(Icons.image),
                label: const Text('Change Image'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateRecipe,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
