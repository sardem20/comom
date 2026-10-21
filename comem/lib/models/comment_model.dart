import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String text;
  final String userId;
  final String userName;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.text,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  // Converte DocumentSnapshot do Firestore para o modelo Dart
  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Usuário',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Converte o modelo Dart para Map enviado ao Firestore
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'text': text,
      'userId': userId,
      'userName': userName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}