import 'package:dartz/dartz.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';

abstract class PostRepository {
  /// Gets all posts from the remote data source
  /// Returns [Either] a [Failure] or a [List] of [Post]
  Future<Either<Failure, List<Post>>> getPosts();

  /// Gets a single post by id from the remote data source
  /// Returns [Either] a [Failure] or a [Post]
  Future<Either<Failure, Post>> getPostById(int id);

  /// Gets all comments for a post by post id from the remote data source
  /// Returns [Either] a [Failure] or a [List] of [Comment]
  Future<Either<Failure, List<Comment>>> getCommentsByPostId(int postId);

  /// Saves a post to local storage for offline reading
  /// Returns [Either] a [Failure] or void on success
  Future<Either<Failure, void>> savePostForOffline(Post post);

  /// Removes a post from local storage
  /// Returns [Either] a [Failure] or void on success
  Future<Either<Failure, void>> unsavePostForOffline(int postId);

  /// Checks if a post is saved for offline reading
  /// Returns [Either] a [Failure] or a [bool] indicating if the post is saved
  Future<Either<Failure, bool>> isPostSavedForOffline(int postId);

  /// Gets all posts saved for offline reading from local storage
  /// Returns [Either] a [Failure] or a [List] of [Post]
  Future<Either<Failure, List<Post>>> getOfflinePosts();

  /// Gets the count of posts saved for offline reading
  /// Returns [Either] a [Failure] or an [int] representing the count
  Future<Either<Failure, int>> getOfflinePostCount();
}

