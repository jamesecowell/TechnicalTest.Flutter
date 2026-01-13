import 'package:dartz/dartz.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';

class GetOfflinePosts {
  final PostRepository repository;

  GetOfflinePosts(this.repository);

  Future<Either<Failure, List<Post>>> call() async {
    return await repository.getOfflinePosts();
  }
}

