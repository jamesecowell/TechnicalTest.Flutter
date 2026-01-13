import 'package:dartz/dartz.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';

abstract class PostRepository {
  /// Gets all posts from the remote data source
  /// Returns [Either] a [Failure] or a [List] of [Post]
  Future<Either<Failure, List<Post>>> getPosts();

  /// Gets a single post by id from the remote data source
  /// Returns [Either] a [Failure] or a [Post]
  Future<Either<Failure, Post>> getPostById(int id);
}

