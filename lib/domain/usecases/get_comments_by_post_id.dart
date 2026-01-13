import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';

class GetCommentsByPostId {
  final PostRepository repository;

  GetCommentsByPostId(this.repository);

  Future<Either<Failure, List<Comment>>> call(GetCommentsByPostIdParams params) async {
    return await repository.getCommentsByPostId(params.postId);
  }
}

class GetCommentsByPostIdParams extends Equatable {
  final int postId;

  const GetCommentsByPostIdParams({required this.postId});

  @override
  List<Object> get props => [postId];
}

