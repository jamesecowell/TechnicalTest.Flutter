import 'package:sqflite/sqflite.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/data/datasources/post_local_data_source.dart';
import 'package:flutter_tech_task/data/models/post_model.dart';

class PostLocalDataSourceImpl implements PostLocalDataSource {
  final Database database;

  PostLocalDataSourceImpl({required this.database});

  @override
  Future<void> savePost(PostModel post) async {
    try {
      await database.insert(
        'posts',
        {
          'id': post.id,
          'userId': post.userId,
          'title': post.title,
          'body': post.body,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save post: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePost(int postId) async {
    try {
      await database.delete(
        'posts',
        where: 'id = ?',
        whereArgs: [postId],
      );
    } catch (e) {
      throw CacheFailure('Failed to delete post: ${e.toString()}');
    }
  }

  @override
  Future<bool> isPostSaved(int postId) async {
    try {
      final result = await database.query(
        'posts',
        where: 'id = ?',
        whereArgs: [postId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      throw CacheFailure('Failed to check if post is saved: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getOfflinePosts() async {
    try {
      final result = await database.query('posts', orderBy: 'id ASC');
      return result
          .map((row) => PostModel.fromJson(
                Map<String, dynamic>.from(row),
              ))
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to get offline posts: ${e.toString()}');
    }
  }

  @override
  Future<int> getOfflinePostCount() async {
    try {
      final result = await database.rawQuery('SELECT COUNT(*) as count FROM posts');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw CacheFailure('Failed to get offline post count: ${e.toString()}');
    }
  }
}

