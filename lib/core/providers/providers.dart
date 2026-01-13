import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
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
import 'package:flutter_tech_task/presentation/viewmodels/offline_post_list_viewmodel.dart';

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

// Repositories - Wait for local data source
final postRepositoryProvider = FutureProvider<PostRepository>((ref) async {
  final localDataSource = await ref.watch(postLocalDataSourceProvider.future);
  return PostRepositoryImpl(
    remoteDataSource: ref.watch(postRemoteDataSourceProvider),
    localDataSource: localDataSource,
  );
});

// Use Cases
final getPostsProvider = FutureProvider<GetPosts>((ref) async {
  final repository = await ref.watch(postRepositoryProvider.future);
  return GetPosts(repository);
});

final getPostByIdProvider = FutureProvider<GetPostById>((ref) async {
  final repository = await ref.watch(postRepositoryProvider.future);
  return GetPostById(repository);
});

final getCommentsByPostIdProvider =
    FutureProvider<GetCommentsByPostId>((ref) async {
  final repository = await ref.watch(postRepositoryProvider.future);
  return GetCommentsByPostId(repository);
});

final savePostForOfflineProvider =
    FutureProvider<SavePostForOffline>((ref) async {
  final repository = await ref.watch(postRepositoryProvider.future);
  return SavePostForOffline(repository);
});

final unsavePostForOfflineProvider =
    FutureProvider<UnsavePostForOffline>((ref) async {
  final repository = await ref.watch(postRepositoryProvider.future);
  return UnsavePostForOffline(repository);
});

final isPostSavedForOfflineProvider =
    FutureProvider<IsPostSavedForOffline>((ref) async {
  final repository = await ref.watch(postRepositoryProvider.future);
  return IsPostSavedForOffline(repository);
});

final getOfflinePostsProvider = FutureProvider<GetOfflinePosts>((ref) async {
  final repository = await ref.watch(postRepositoryProvider.future);
  return GetOfflinePosts(repository);
});

final getOfflinePostCountProvider =
    FutureProvider<GetOfflinePostCount>((ref) async {
  final repository = await ref.watch(postRepositoryProvider.future);
  return GetOfflinePostCount(repository);
});

// ViewModels - Wait for dependencies before creating
final postListViewModelProvider =
    StateNotifierProvider<PostListViewModel, AsyncValue<List<Post>>>((ref) {
  // Wait for use case to be ready
  final getPostsAsync = ref.watch(getPostsProvider);

  return getPostsAsync.when(
    data: (getPosts) => PostListViewModel(getPosts: getPosts),
    loading: () =>
        PostListViewModel(getPosts: GetPosts(_PlaceholderRepository())),
    error: (_, __) =>
        PostListViewModel(getPosts: GetPosts(_PlaceholderRepository())),
  );
});

final postDetailsViewModelProvider =
    StateNotifierProvider<PostDetailsViewModel, AsyncValue<Post>>((ref) {
  final getPostByIdAsync = ref.watch(getPostByIdProvider);
  final isPostSavedAsync = ref.watch(isPostSavedForOfflineProvider);
  final savePostAsync = ref.watch(savePostForOfflineProvider);
  final unsavePostAsync = ref.watch(unsavePostForOfflineProvider);

  // Wait for all dependencies to be ready
  return getPostByIdAsync.when(
    data: (getPostById) => isPostSavedAsync.when(
      data: (isPostSaved) => savePostAsync.when(
        data: (savePost) => unsavePostAsync.when(
          data: (unsavePost) => PostDetailsViewModel(
            getPostById: getPostById,
            isPostSavedForOffline: isPostSaved,
            savePostForOffline: savePost,
            unsavePostForOffline: unsavePost,
          ),
          loading: () => PostDetailsViewModel(
            getPostById: getPostById,
            isPostSavedForOffline: isPostSaved,
            savePostForOffline: savePost,
            unsavePostForOffline:
                UnsavePostForOffline(_PlaceholderRepository()),
          ),
          error: (_, __) => PostDetailsViewModel(
            getPostById: getPostById,
            isPostSavedForOffline: isPostSaved,
            savePostForOffline: savePost,
            unsavePostForOffline:
                UnsavePostForOffline(_PlaceholderRepository()),
          ),
        ),
        loading: () => PostDetailsViewModel(
          getPostById: getPostById,
          isPostSavedForOffline: isPostSaved,
          savePostForOffline: SavePostForOffline(_PlaceholderRepository()),
          unsavePostForOffline: UnsavePostForOffline(_PlaceholderRepository()),
        ),
        error: (_, __) => PostDetailsViewModel(
          getPostById: getPostById,
          isPostSavedForOffline: isPostSaved,
          savePostForOffline: SavePostForOffline(_PlaceholderRepository()),
          unsavePostForOffline: UnsavePostForOffline(_PlaceholderRepository()),
        ),
      ),
      loading: () => PostDetailsViewModel(
        getPostById: getPostById,
        isPostSavedForOffline: IsPostSavedForOffline(_PlaceholderRepository()),
        savePostForOffline: SavePostForOffline(_PlaceholderRepository()),
        unsavePostForOffline: UnsavePostForOffline(_PlaceholderRepository()),
      ),
      error: (_, __) => PostDetailsViewModel(
        getPostById: getPostById,
        isPostSavedForOffline: IsPostSavedForOffline(_PlaceholderRepository()),
        savePostForOffline: SavePostForOffline(_PlaceholderRepository()),
        unsavePostForOffline: UnsavePostForOffline(_PlaceholderRepository()),
      ),
    ),
    loading: () => PostDetailsViewModel(
      getPostById: GetPostById(_PlaceholderRepository()),
      isPostSavedForOffline: IsPostSavedForOffline(_PlaceholderRepository()),
      savePostForOffline: SavePostForOffline(_PlaceholderRepository()),
      unsavePostForOffline: UnsavePostForOffline(_PlaceholderRepository()),
    ),
    error: (_, __) => PostDetailsViewModel(
      getPostById: GetPostById(_PlaceholderRepository()),
      isPostSavedForOffline: IsPostSavedForOffline(_PlaceholderRepository()),
      savePostForOffline: SavePostForOffline(_PlaceholderRepository()),
      unsavePostForOffline: UnsavePostForOffline(_PlaceholderRepository()),
    ),
  );
});

final offlinePostListViewModelProvider =
    StateNotifierProvider<OfflinePostListViewModel, AsyncValue<List<Post>>>(
        (ref) {
  final getOfflinePostsAsync = ref.watch(getOfflinePostsProvider);

  return getOfflinePostsAsync.when(
    data: (getOfflinePosts) =>
        OfflinePostListViewModel(getOfflinePosts: getOfflinePosts),
    loading: () => OfflinePostListViewModel(
        getOfflinePosts: GetOfflinePosts(_PlaceholderRepository())),
    error: (_, __) => OfflinePostListViewModel(
        getOfflinePosts: GetOfflinePosts(_PlaceholderRepository())),
  );
});

final commentsViewModelProvider =
    StateNotifierProvider<CommentsViewModel, AsyncValue<List<Comment>>>((ref) {
  final getCommentsAsync = ref.watch(getCommentsByPostIdProvider);

  return getCommentsAsync.when(
    data: (getComments) => CommentsViewModel(getCommentsByPostId: getComments),
    loading: () => CommentsViewModel(
        getCommentsByPostId: GetCommentsByPostId(_PlaceholderRepository())),
    error: (_, __) => CommentsViewModel(
        getCommentsByPostId: GetCommentsByPostId(_PlaceholderRepository())),
  );
});

// Provider for saved status - watches the ViewModel's savedStatusNotifier
final postDetailsSavedStatusProvider =
    StateNotifierProvider<SavedStatusNotifier, AsyncValue<bool>>((ref) {
  // Get the ViewModel and use its savedStatusNotifier
  final viewModel = ref.watch(postDetailsViewModelProvider.notifier);
  // Return the ViewModel's savedStatusNotifier so updates propagate
  return viewModel.savedStatusNotifier;
});

// Placeholder repository for initialization
class _PlaceholderRepository implements PostRepository {
  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    throw UnimplementedError('Repository not initialized yet');
  }

  @override
  Future<Either<Failure, Post>> getPostById(int id) async {
    throw UnimplementedError('Repository not initialized yet');
  }

  @override
  Future<Either<Failure, List<Comment>>> getCommentsByPostId(int postId) async {
    throw UnimplementedError('Repository not initialized yet');
  }

  @override
  Future<Either<Failure, void>> savePostForOffline(Post post) async {
    throw UnimplementedError('Repository not initialized yet');
  }

  @override
  Future<Either<Failure, void>> unsavePostForOffline(int postId) async {
    throw UnimplementedError('Repository not initialized yet');
  }

  @override
  Future<Either<Failure, bool>> isPostSavedForOffline(int postId) async {
    throw UnimplementedError('Repository not initialized yet');
  }

  @override
  Future<Either<Failure, List<Post>>> getOfflinePosts() async {
    throw UnimplementedError('Repository not initialized yet');
  }

  @override
  Future<Either<Failure, int>> getOfflinePostCount() async {
    throw UnimplementedError('Repository not initialized yet');
  }
}
