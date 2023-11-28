import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String userId;
  final String username;
  final String userProfilePictureUrl;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.userId,
    required this.username,
    required this.userProfilePictureUrl,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    return Comment(
      userId: doc['userId'],
      username: doc['username'],
      userProfilePictureUrl: doc['userProfilePictureUrl'],
      text: doc['text'],
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'userProfilePictureUrl': userProfilePictureUrl,
      'text': text,
      'timestamp': timestamp,
    };
  }
}