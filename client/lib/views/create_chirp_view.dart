import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chirp_viewmodel.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class CreateChirpView extends StatefulWidget {
  final String? replyToId;

  const CreateChirpView({super.key, this.replyToId});

  @override
  State<CreateChirpView> createState() => _CreateChirpViewState();
}

class _CreateChirpViewState extends State<CreateChirpView> {
  final _contentController = TextEditingController();
  bool _isPosting = false;
  final List<File> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_imageFiles.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 5 imágenes permitidas')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFiles.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  Future<void> _handlePost() async {
    if (_contentController.text.trim().isEmpty && _imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El chirp no puede estar vacío')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    final chirpViewModel = Provider.of<ChirpViewModel>(context, listen: false);
    final success = await chirpViewModel.createChirp(
      _contentController.text.trim(),
      replyToId: widget.replyToId,
      imagePaths: _imageFiles.map((e) => e.path).toList(),
    );

    setState(() {
      _isPosting = false;
    });

    if (success && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted && chirpViewModel.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(chirpViewModel.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.replyToId != null ? 'Responder' : 'Nuevo Chirp'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 80,
              child: CustomButton(
                text: 'Chirp',
                onPressed: _handlePost,
                isLoading: _isPosting,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _contentController,
                hintText: '¿Qué está pasando?',
                maxLines: null,
                maxLength: 280,
              ),
            ),
            if (_imageFiles.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_imageFiles[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, color: Colors.blue),
                ),
                Text(
                  '${_contentController.text.length}/280',
                  style: TextStyle(
                    color: _contentController.text.length > 280
                        ? Colors.red
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
