import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';

class UnsavePostForOffline {
  final PostRepository repository;

  UnsavePostForOffline(this.repository);

  Future<Either<Failure, void>> call(UnsavePostForOfflineParams params) async {
    return await repository.unsavePostForOffline(params.postId);
  }
}

class UnsavePostForOfflineParams extends Equatable {
  final int postId;

  const UnsavePostForOfflineParams({required this.postId});

  @override
  List<Object> get props => [postId];
}

