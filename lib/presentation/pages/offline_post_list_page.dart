import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tech_task/core/providers/providers.dart';
import 'package:flutter_tech_task/presentation/utils/error_message_extractor.dart';
import 'package:flutter_tech_task/presentation/widgets/error_widget.dart';
import 'package:flutter_tech_task/presentation/widgets/loading_widget.dart';
import 'package:flutter_tech_task/presentation/widgets/post_list_item.dart';

class OfflinePostListPage extends ConsumerStatefulWidget {
  const OfflinePostListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OfflinePostListPage> createState() =>
      _OfflinePostListPageState();
}

class _OfflinePostListPageState extends ConsumerState<OfflinePostListPage> {
  @override
  void initState() {
    super.initState();
    // ViewModel will auto-load when created with real repository
    // But also try to load in case it's already ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(offlinePostListViewModelProvider.notifier).loadOfflinePosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(offlinePostListViewModelProvider);

    return Scaffold(
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
          return ErrorDisplayWidget(
            message: extractErrorMessage(error),
            onRetry: () {
              ref
                  .read(offlinePostListViewModelProvider.notifier)
                  .loadOfflinePosts();
            },
          );
        },
      ),
    );
  }
}
