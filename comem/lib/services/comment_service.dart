import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Coleção principal de comentários
  CollectionReference get _commentsRef => _firestore.collection('comments');

  // Adicionar comentário no Firestore
  Future<void> addComment({
    required String postId,
    required String text,
    required String userId,
    required String userName,
  }) async {
    await _commentsRef.add({
      'postId': postId,
      'text': text,
      'userId': userId,
      'userName': userName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Obter Stream dos comentários em TEMPO REAL filtrados por publicação
  Stream<List<CommentModel>> getCommentsByPostId(String postId) {
    return _commentsRef
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList());
  }

  // Deletar comentário
  Future<void> deleteComment(String commentId) async {
    await _commentsRef.doc(commentId).delete();
  }
}