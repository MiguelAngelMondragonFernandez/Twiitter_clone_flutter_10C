import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../viewmodels/auth_viewmodel.dart';

class EditProfileView extends StatefulWidget {
  final User user;

  const EditProfileView({super.key, required this.user});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.user.displayName ?? widget.user.username,
    );
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _cityController = TextEditingController(text: widget.user.city ?? '');
    _countryController = TextEditingController(text: widget.user.country ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setState(() {
                    _imageFile = File(image.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  setState(() {
                    _imageFile = File(image.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

    Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authViewModel.updateProfile(
      displayName: _displayNameController.text,
      bio: _bioController.text,
      city: _cityController.text,
      country: _countryController.text,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.error ?? 'Error al actualizar perfil'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          if (authViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : (widget.user.fullProfileImageUrl != null
                                    ? NetworkImage(widget.user.fullProfileImageUrl!)
                                    : null) as ImageProvider?,
                            child: _imageFile == null &&
                                    widget.user.fullProfileImageUrl == null
                                ? Text(
                                    widget.user.username[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Display Name Field
                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                      helperText: 'El nombre que se mostrará en tu perfil',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un nombre';
                      }
                      if (value.length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      }
                      if (value.length > 50) {
                        return 'El nombre no puede exceder 50 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Bio Field
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Biografía',
                      border: OutlineInputBorder(),
                      helperText: 'Cuéntanos sobre ti',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value != null && value.length > 160) {
                        return 'La biografía no puede exceder 160 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // City Field
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      border: OutlineInputBorder(),
                      helperText: 'Tu ciudad actual',
                    ),
                    validator: (value) {
                      if (value != null && value.length > 100) {
                        return 'La ciudad no puede exceder 100 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Country Field
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'País',
                      border: OutlineInputBorder(),
                      helperText: 'Tu país de residencia',
                    ),
                    validator: (value) {
                      if (value != null && value.length > 100) {
                        return 'El país no puede exceder 100 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
