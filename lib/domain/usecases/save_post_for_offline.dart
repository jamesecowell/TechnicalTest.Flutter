import 'package:dartz/dartz.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';

class SavePostForOffline {
  final PostRepository repository;

  SavePostForOffline(this.repository);

  Future<Either<Failure, void>> call(Post post) async {
    return await repository.savePostForOffline(post);
  }
}

