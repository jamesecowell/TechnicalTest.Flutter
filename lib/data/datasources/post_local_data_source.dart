import 'package:flutter_tech_task/data/models/post_model.dart';

/// Abstract class for local data source operations
/// Handles saving, retrieving, and managing posts in local storage
abstract class PostLocalDataSource {
  /// Saves a post to local storage for offline reading
  /// Throws [CacheFailure] if the operation fails
  Future<void> savePost(PostModel post);

  /// Deletes a post from local storage
  /// Throws [CacheFailure] if the operation fails
  Future<void> deletePost(int postId);

  /// Checks if a post is saved in local storage
  /// Returns true if the post exists, false otherwise
  /// Throws [CacheFailure] if the operation fails
  Future<bool> isPostSaved(int postId);

  /// Retrieves all posts saved for offline reading
  /// Returns an empty list if no posts are saved
  /// Throws [CacheFailure] if the operation fails
  Future<List<PostModel>> getOfflinePosts();

  /// Gets the count of posts saved for offline reading
  /// Returns 0 if no posts are saved
  /// Throws [CacheFailure] if the operation fails
  Future<int> getOfflinePostCount();
}

