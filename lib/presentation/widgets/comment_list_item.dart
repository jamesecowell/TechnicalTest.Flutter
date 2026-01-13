import 'package:flutter/material.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';

class CommentListItem extends StatelessWidget {
  final Comment comment;

  const CommentListItem({
    Key? key,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            comment.email,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(comment.body),
          const SizedBox(height: 10),
          const Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
