import 'package:dartz/dartz.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';

class GetOfflinePostCount {
  final PostRepository repository;

  GetOfflinePostCount(this.repository);

  Future<Either<Failure, int>> call() async {
    return await repository.getOfflinePostCount();
  }
}

