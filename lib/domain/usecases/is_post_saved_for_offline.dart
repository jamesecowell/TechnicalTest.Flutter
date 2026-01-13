import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';

class IsPostSavedForOffline {
  final PostRepository repository;

  IsPostSavedForOffline(this.repository);

  Future<Either<Failure, bool>> call(IsPostSavedForOfflineParams params) async {
    return await repository.isPostSavedForOffline(params.postId);
  }
}

class IsPostSavedForOfflineParams extends Equatable {
  final int postId;

  const IsPostSavedForOfflineParams({required this.postId});

  @override
  List<Object> get props => [postId];
}

