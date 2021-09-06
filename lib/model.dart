import 'dart:core';

class SecretModel {
  final String id;
  final String secret;
  final String author;

  SecretModel({
    required this.id,
    required this.secret,
    required this.author,
  });

  factory SecretModel.fromSearch(Map data) {
    print(data);
    return SecretModel(
      id: '${data['sid']}',
      secret: data['secret']! as String,
      author: data['author']! as String,
    );
  }
}
