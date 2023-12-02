import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String userId;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.userId,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    return Comment(
      userId: doc['userId'],
      text: doc['text'],
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}