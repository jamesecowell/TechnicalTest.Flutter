import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';

class GetPostById {
  final PostRepository repository;

  GetPostById(this.repository);

  Future<Either<Failure, Post>> call(GetPostByIdParams params) async {
    return await repository.getPostById(params.id);
  }
}

class GetPostByIdParams extends Equatable {
  final int id;

  const GetPostByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}

