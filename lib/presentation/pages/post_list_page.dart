import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/core/providers/providers.dart';
import 'package:flutter_tech_task/presentation/widgets/error_widget.dart';
import 'package:flutter_tech_task/presentation/widgets/loading_widget.dart';
import 'package:flutter_tech_task/presentation/widgets/post_list_item.dart';

class PostListPage extends ConsumerStatefulWidget {
  const PostListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends ConsumerState<PostListPage> {
  @override
  void initState() {
    super.initState();
    // Load posts when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postListViewModelProvider.notifier).loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('List of posts'),
      ),
      body: postsState.when(
        data: (posts) => ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostListItem(
              post: post,
              onTap: () {
                Navigator.of(context).pushNamed(
                  'details/',
                  arguments: {'id': post.id},
                );
              },
            );
          },
        ),
        loading: () => const LoadingWidget(),
        error: (error, stackTrace) {
          String errorMessage = 'An error occurred';
          if (error is ServerFailure) {
            errorMessage = error.message;
          } else if (error is NetworkFailure) {
            errorMessage = error.message;
          } else if (error is CacheFailure) {
            errorMessage = error.message;
          } else {
            errorMessage = error.toString();
          }
          return ErrorDisplayWidget(
            message: errorMessage,
            onRetry: () {
              ref.read(postListViewModelProvider.notifier).loadPosts();
            },
          );
        },
      ),
    );
  }
}
