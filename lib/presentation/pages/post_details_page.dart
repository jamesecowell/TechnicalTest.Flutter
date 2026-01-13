import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tech_task/core/providers/providers.dart';
import 'package:flutter_tech_task/presentation/utils/error_message_extractor.dart';
import 'package:flutter_tech_task/presentation/widgets/error_widget.dart';
import 'package:flutter_tech_task/presentation/widgets/loading_widget.dart';

class PostDetailsPage extends ConsumerStatefulWidget {
  const PostDetailsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends ConsumerState<PostDetailsPage> {
  int? _postId;
  bool _hasRetriedAfterReady = false;

  void _loadPostFromArguments() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    _postId = args?['id'] as int?;
    if (_postId != null) {
      ref.read(postDetailsViewModelProvider.notifier).loadPost(_postId!);
    }
  }

  @override
  void initState() {
    super.initState();
    // Load post when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPostFromArguments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postDetailsViewModelProvider);
    final viewModel = ref.watch(postDetailsViewModelProvider.notifier);
    final savedStatus = ref.watch(postDetailsSavedStatusProvider);

    // Watch use case providers - when they become ready, retry loading if needed
    final getPostByIdAsync = ref.watch(getPostByIdProvider);
    getPostByIdAsync.maybeWhen(
      data: (_) {
        // Use case is ready - if we have a postId, state is loading, and we haven't retried yet
        if (_postId != null && postState.isLoading && !_hasRetriedAfterReady) {
          _hasRetriedAfterReady = true;
          Future.microtask(() {
            if (mounted && _postId != null) {
              final currentState = ref.read(postDetailsViewModelProvider);
              // Only retry if still loading (might be a new ViewModel instance)
              if (currentState.isLoading) {
                ref
                    .read(postDetailsViewModelProvider.notifier)
                    .loadPost(_postId!);
              }
            }
          });
        }
      },
      orElse: () {},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post details'),
        actions: [
          postState.when(
            data: (post) => savedStatus.when(
              data: (isSaved) => IconButton(
                icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () async {
                  await viewModel.toggleSavePost(post);
                  // Refresh offline post list to update badge count
                  ref
                      .read(offlinePostListViewModelProvider.notifier)
                      .loadOfflinePosts();
                },
                tooltip: isSaved ? 'Remove from offline' : 'Save for offline',
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () async {
                  final post = postState.value;
                  if (post != null) {
                    await viewModel.toggleSavePost(post);
                    // Refresh offline post list to update badge count
                    ref
                        .read(offlinePostListViewModelProvider.notifier)
                        .loadOfflinePosts();
                  }
                },
                tooltip: 'Save for offline',
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
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
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      'comments/',
                      arguments: {'postId': post.id},
                    );
                  },
                  child: const Text('View Comments'),
                ),
              ),
            ],
          ),
        ),
        loading: () => const LoadingWidget(),
        error: (error, stackTrace) {
          return ErrorDisplayWidget(
            message: extractErrorMessage(error),
            onRetry: _loadPostFromArguments,
          );
        },
      ),
    );
  }
}
