import 'package:dartz/dartz.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/data/datasources/post_remote_data_source.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    try {
      final remotePosts = await remoteDataSource.getPosts();
      return Right(remotePosts.map((model) => model.toEntity()).toList());
    } on ServerFailure catch (failure) {
      return Left(failure);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Post>> getPostById(int id) async {
    try {
      final remotePost = await remoteDataSource.getPostById(id);
      return Right(remotePost.toEntity());
    } on ServerFailure catch (failure) {
      return Left(failure);
    } on NetworkFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
