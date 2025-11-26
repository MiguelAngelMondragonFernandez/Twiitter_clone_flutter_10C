import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chirp.dart';
import '../services/chirp_service.dart';
import '../widgets/chirp_card.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/chirp_viewmodel.dart';

class ChirpDetailView extends StatefulWidget {
  final Chirp chirp;

  const ChirpDetailView({super.key, required this.chirp});

  @override
  State<ChirpDetailView> createState() => _ChirpDetailViewState();
}

class _ChirpDetailViewState extends State<ChirpDetailView> {
  final ChirpService _chirpService = ChirpService();
  final TextEditingController _replyController = TextEditingController();
  List<Chirp> _replies = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadReplies() async {
    try {
      final replies = await _chirpService.getReplies(widget.chirp.id);
      if (mounted) {
        setState(() {
          _replies = replies;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading replies: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar respuestas: $e')),
        );
      }
    }
  }

  Future<void> _sendReply() async {
    if (_replyController.text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      final newReply = await _chirpService.createChirp(
        _replyController.text,
        replyToId: widget.chirp.id,
      );
      
      if (mounted) {
        setState(() {
          _replies.insert(0, newReply);
          _replyController.clear();
          _isSending = false;
        });
        
        // Update the main chirp's reply count in the view model if needed
        // This is a bit tricky since we passed the chirp object directly
        // Ideally we would reload the main chirp too
      }
    } catch (e) {
      print('Error sending reply: $e');
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar respuesta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chirp'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadReplies,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    ChirpCard(chirp: widget.chirp),
                    const Divider(height: 1),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_replies.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'Sé el primero en responder',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _replies.length,
                        itemBuilder: (context, index) {
                          return ChirpCard(chirp: _replies[index]);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      decoration: const InputDecoration(
                        hintText: 'Chirpea tu respuesta',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSending ? null : _sendReply,
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.send,
                            color: Theme.of(context).primaryColor,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
