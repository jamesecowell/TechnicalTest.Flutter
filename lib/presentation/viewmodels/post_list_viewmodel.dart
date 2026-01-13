import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/usecases/get_posts.dart';

class PostListViewModel extends StateNotifier<AsyncValue<List<Post>>> {
  final GetPosts getPosts;

  PostListViewModel({required this.getPosts})
      : super(const AsyncValue.loading());

  Future<void> loadPosts() async {
    state = const AsyncValue.loading();
    try {
      final result = await getPosts();
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (posts) => state = AsyncValue.data(posts),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
