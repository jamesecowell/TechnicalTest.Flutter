import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tech_task/data/datasources/post_remote_data_source.dart';
import 'package:flutter_tech_task/data/repositories/post_repository_impl.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';
import 'package:flutter_tech_task/domain/usecases/get_posts.dart';
import 'package:flutter_tech_task/domain/usecases/get_post_by_id.dart';
import 'package:flutter_tech_task/domain/usecases/get_comments_by_post_id.dart';
import 'package:flutter_tech_task/presentation/viewmodels/post_list_viewmodel.dart';
import 'package:flutter_tech_task/presentation/viewmodels/post_details_viewmodel.dart';
import 'package:flutter_tech_task/presentation/viewmodels/comments_viewmodel.dart';

// HTTP Client Provider
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// Data Sources
final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  return PostRemoteDataSourceImpl(client: ref.watch(httpClientProvider));
});

// Repositories
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    remoteDataSource: ref.watch(postRemoteDataSourceProvider),
  );
});

// Use Cases
final getPostsProvider = Provider<GetPosts>((ref) {
  return GetPosts(ref.watch(postRepositoryProvider));
});

final getPostByIdProvider = Provider<GetPostById>((ref) {
  return GetPostById(ref.watch(postRepositoryProvider));
});

final getCommentsByPostIdProvider = Provider<GetCommentsByPostId>((ref) {
  return GetCommentsByPostId(ref.watch(postRepositoryProvider));
});

// ViewModels
final postListViewModelProvider =
    StateNotifierProvider<PostListViewModel, AsyncValue<List<Post>>>((ref) {
  return PostListViewModel(getPosts: ref.watch(getPostsProvider));
});

final postDetailsViewModelProvider =
    StateNotifierProvider<PostDetailsViewModel, AsyncValue<Post>>((ref) {
  return PostDetailsViewModel(getPostById: ref.watch(getPostByIdProvider));
});

final commentsViewModelProvider =
    StateNotifierProvider<CommentsViewModel, AsyncValue<List<Comment>>>((ref) {
  return CommentsViewModel(
      getCommentsByPostId: ref.watch(getCommentsByPostIdProvider));
});
