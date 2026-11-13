import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/chat_view_model.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit(ChatViewModel viewModel) async {
    if (viewModel.isLoading) return;
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    await viewModel.sendQuestion(text);
    if (mounted) _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sohbet')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              itemCount: viewModel.messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: viewModel.messages[index]);
              },
            ),
          ),
          if (viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Asistan düşünüyor...'),
                ],
              ),
            ),
          if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !viewModel.isLoading,
                      decoration: const InputDecoration(
                        hintText: 'Sorunuzu yazın...',
                      ),
                      onSubmitted: viewModel.isLoading
                          ? null
                          : (_) => _submit(viewModel),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        viewModel.isLoading ? null : () => _submit(viewModel),
                    icon: const Icon(Icons.send),
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
