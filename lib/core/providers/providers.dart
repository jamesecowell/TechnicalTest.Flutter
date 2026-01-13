import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:flutter_tech_task/data/datasources/database_helper.dart';
import 'package:flutter_tech_task/data/datasources/post_local_data_source.dart';
import 'package:flutter_tech_task/data/datasources/post_local_data_source_impl.dart';
import 'package:flutter_tech_task/data/datasources/post_remote_data_source.dart';
import 'package:flutter_tech_task/data/repositories/post_repository_impl.dart';
import 'package:flutter_tech_task/domain/entities/comment.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/repositories/post_repository.dart';
import 'package:flutter_tech_task/domain/usecases/get_posts.dart';
import 'package:flutter_tech_task/domain/usecases/get_post_by_id.dart';
import 'package:flutter_tech_task/domain/usecases/get_comments_by_post_id.dart';
import 'package:flutter_tech_task/domain/usecases/save_post_for_offline.dart';
import 'package:flutter_tech_task/domain/usecases/unsave_post_for_offline.dart';
import 'package:flutter_tech_task/domain/usecases/is_post_saved_for_offline.dart';
import 'package:flutter_tech_task/domain/usecases/get_offline_posts.dart';
import 'package:flutter_tech_task/domain/usecases/get_offline_post_count.dart';
import 'package:flutter_tech_task/presentation/viewmodels/post_list_viewmodel.dart';
import 'package:flutter_tech_task/presentation/viewmodels/post_details_viewmodel.dart';
import 'package:flutter_tech_task/presentation/viewmodels/comments_viewmodel.dart';

// HTTP Client Provider
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// Database Provider
final databaseProvider = FutureProvider<Database>((ref) async {
  return await DatabaseHelper.instance.database;
});

// Data Sources
final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  return PostRemoteDataSourceImpl(client: ref.watch(httpClientProvider));
});

final postLocalDataSourceProvider =
    FutureProvider<PostLocalDataSource>((ref) async {
  final database = await ref.watch(databaseProvider.future);
  return PostLocalDataSourceImpl(database: database);
});

// Repositories
final postRepositoryProvider = Provider<PostRepository>((ref) {
  final localDataSource = ref.watch(postLocalDataSourceProvider);
  return PostRepositoryImpl(
    remoteDataSource: ref.watch(postRemoteDataSourceProvider),
    localDataSource: localDataSource.requireValue,
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

final savePostForOfflineProvider = Provider<SavePostForOffline>((ref) {
  return SavePostForOffline(ref.watch(postRepositoryProvider));
});

final unsavePostForOfflineProvider = Provider<UnsavePostForOffline>((ref) {
  return UnsavePostForOffline(ref.watch(postRepositoryProvider));
});

final isPostSavedForOfflineProvider = Provider<IsPostSavedForOffline>((ref) {
  return IsPostSavedForOffline(ref.watch(postRepositoryProvider));
});

final getOfflinePostsProvider = Provider<GetOfflinePosts>((ref) {
  return GetOfflinePosts(ref.watch(postRepositoryProvider));
});

final getOfflinePostCountProvider = Provider<GetOfflinePostCount>((ref) {
  return GetOfflinePostCount(ref.watch(postRepositoryProvider));
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
