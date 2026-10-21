import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  final String postText;
  final String postAuthor;

  const CommentsPage({
    Key? key,
    required this.postId,
    required this.postText,
    required this.postAuthor,
  }) : super(key: key);

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || currentUser == null) return;

    _commentController.clear();

    await _commentService.addComment(
      postId: widget.postId,
      text: text,
      userId: currentUser!.uid,
      userName: currentUser!.displayName ?? currentUser!.email?.split('@')[0] ?? 'Anônimo',
    );
  }

  void _deleteComment(String commentId) async {
    try {
      await _commentService.deleteComment(commentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentário removido com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentários'),
      ),
      body: Column(
        children: [
          // Exibição da Publicação Selecionada
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade200,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.postAuthor,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.postText,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Lista de Comentários Atualizados em Tempo Real (StreamBuilder)
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: _commentService.getCommentsByPostId(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return const Center(
                    child: Text('Nenhum comentário ainda. Seja o primeiro a comentar!'),
                  );
                }

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isMyComment = comment.userId == currentUser?.uid;

                    return ListTile(
                      title: Text(
                        comment.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(comment.text),
                      trailing: isMyComment
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteComment(comment.id),
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),

          // Campo para digitar novo comentário
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Escreva um comentário...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendComment,
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