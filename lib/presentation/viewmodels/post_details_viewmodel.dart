import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tech_task/domain/entities/post.dart';
import 'package:flutter_tech_task/domain/usecases/get_post_by_id.dart';

class PostDetailsViewModel extends StateNotifier<AsyncValue<Post>> {
  final GetPostById getPostById;

  PostDetailsViewModel({required this.getPostById}) : super(const AsyncValue.loading());

  Future<void> loadPost(int id) async {
    state = const AsyncValue.loading();
    try {
      final result = await getPostById(GetPostByIdParams(id: id));
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (post) => state = AsyncValue.data(post),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

