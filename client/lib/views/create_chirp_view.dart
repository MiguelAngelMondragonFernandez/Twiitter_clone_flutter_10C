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

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handlePost() async {
    if (_contentController.text.trim().isEmpty) {
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
                maxLines: 0,
                maxLength: 280,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
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
