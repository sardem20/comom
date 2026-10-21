import 'package:flutter/material.dart';
import 'comments_page.dart';

// No método buildItem do Card da Publicação (Exemplo):
Widget buildPostCard(BuildContext context, dynamic post) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post['userName'] ?? 'Anônimo',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(post['content'] ?? ''),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.comment_outlined),
                label: const Text('Comentários'),
                onPressed: () {
                  // Navega para a tela de comentários passando os dados do post
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsPage(
                        postId: post['id'], // ID do documento da publicação
                        postText: post['content'] ?? '',
                        postAuthor: post['userName'] ?? 'Autor',
                      ),
                    ),
                  );
                },
              ),
            ],
          )
        ],
      ),
    ),
  );
}