import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tech_task/core/error/failures.dart';
import 'package:flutter_tech_task/core/providers/providers.dart';
import 'package:flutter_tech_task/presentation/widgets/error_widget.dart';
import 'package:flutter_tech_task/presentation/widgets/loading_widget.dart';

class PostDetailsPage extends ConsumerStatefulWidget {
  const PostDetailsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends ConsumerState<PostDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Load post when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final postId = args?['id'] as int?;
      if (postId != null) {
        ref.read(postDetailsViewModelProvider.notifier).loadPost(postId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postDetailsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post details'),
      ),
      body: postState.when(
        data: (post) => Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                post.body,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
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
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
              final postId = args?['id'] as int?;
              if (postId != null) {
                ref
                    .read(postDetailsViewModelProvider.notifier)
                    .loadPost(postId);
              }
            },
          );
        },
      ),
    );
  }
}
